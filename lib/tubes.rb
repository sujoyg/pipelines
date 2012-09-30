require 'json'

class Tube
  attr :dir
  attr :ended_at
  attr :exception
  attr :name
  attr :order
  attr :output
  attr :started_at
  attr :stats
  attr :thread_lock
  attr :threads

  def initialize(dir=nil, options={})
    @dir = dir || File.join('/tmp', Time.now.strftime('%Y-%m-%d_%H:%M:%S'))
    @type = options.delete(:type) || :serial
    @parent = options.delete(:parent) # This is nil only for the top level tube.

    @serial_count = 0
    @parallel_count = 0

    @thread_lock = @parent ? @parent.thread_lock : Mutex.new
    @stats = @parent ? @parent.stats : {}

    @name = underscore self.class.name.split('::')[-1]
    @order = options.delete(:order) || ''

    @input = options.delete(:input)
    @output = @type == :serial ? nil : []

    @threads = []

    @options = options
    @step = nil
    @ended_at = nil
    @started_at = options[:started_at] || Time.now
    @invocations = 0

    Dir.mkdir(@dir) unless Dir.exists?(@dir)

    if @parent.nil? # This is the top level tube.
      class << self
        alias_method :unlocked_run, :run

        def run(*args, &block)
          lock
          unlocked_run(*args, &block)
          unlock
          notify
        end
      end
    end
  end


  def serial(args=nil, &block)
    tube(:serial, args, &block)
  end


  def parallel(args=nil, &block)
    tube(:parallel, args, &block)
  end


  def invoke(klass, *args)
    @invocations += 1

    options = {:order => @order, :parent => self}
    segment = klass.new @dir, options

    step = segment.name

    output_file = segment_cache self, step
    if File.exists?(output_file)
      self.puts "Skipping: #{step}"
      @output = JSON.load(File.read(output_file))["data"]
      if @type == :serial
        @input = @output
      end
    else
      self.puts "Running: #{step}"

      if @type == :serial
        dispatch(segment, output_file, *args)
        @input = @output
      elsif @type == :parallel
        thread = Thread.new(@thread_lock) do |lock|
          Thread.current[:lock] = lock
          Thread.current.abort_on_exception = true

          dispatch(segment, output_file, *args)
        end
        @threads << thread
      end
    end

    Thread.current[:step] = step
  end


  def puts(string='')
    @thread_lock.synchronize do
      if self.class == Tube
        Kernel.puts "\033[32m[#{@order}]\033[0m #{string}"
      else
        Kernel.puts "\033[32m[#{@order}]\033[0m\033[36m[#{@name}]\033[0m #{string}"
      end

      STDOUT.flush
    end

    nil # Behave like Kernel.puts
  end


  private

  def tube(mode, args=nil, &block)
    begin
      case @type
        when :parallel # When inside parallel.
          thread = Thread.new(@thread_lock) do |lock|
            Thread.current[:lock] = lock
            Thread.current.abort_on_exception = true

            tube = child(mode, args)
            tube.instance_eval &block
            tube.threads.each { |thread| thread.join } # Could be a parallel block inside a parallel block.
            @thread_lock.synchronize do
              @output << mode == :parallel ? tube.output.flatten(1) : tube.output
            end
          end
          @threads << thread
        when :serial # When inside serial.
          tube = child(mode, args)
          tube.instance_eval &block
          tube.threads.each { |thread| thread.join }
          @output = mode == :parallel ? tube.output.flatten(1) : tube.output
          @input = @output
      end
    rescue => e
      @exception = e
      notify
      raise
    end
  end

  def notify
    # This should be implemented in the subclasses.
  end

  def dispatch(segment, output_file, *args)
    output = if segment.method(:run).arity > 0 # Optional arguments result in negative arity.
               if args.empty?
                 if @invocations > 1
                   segment.send :run, @input
                 else
                   segment.send :run # This should raise an argument mismatch error.
                 end
               else
                 segment.send :run, *args
               end
             elsif segment.method(:run).arity < 0
               if args.empty?
                 if @invocations > 1
                   segment.send :run, @input
                 else
                   segment.send :run
                 end
               else
                 segment.send :run, *args
               end
             else
               segment.send :run
             end

    File.open(output_file, "w") do |f|
      f.write({:data => output}.to_json)
    end

    if @type == :serial
      @output = output
    elsif @type == :parallel
      @thread_lock.synchronize do
        @output << output
      end
    end
  end


  def segment_cache(tube, segment)
    File.join tube.dir, "#{tube.order}-#{@invocations}-#{segment}.json"
  end


  def child(type, args=nil)
    order = case type
              when :serial
                @serial_count += 1
                "#{@order}S#{@serial_count}"
              when :parallel
                @parallel_count += 1
                "#{@order}P#{@parallel_count}"
            end

    Tube.new(@dir, :type => type, :input => args || @input, :parent => self, :order => order, :started_at => started_at)
  end

  def underscore(string)
    string.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr("-", "_").downcase
  end

  def lock
    lock = File.join @dir, "lock"
    if !@options[:force] && File.exists?(lock)
      raise "Another instance of the tubes seems to be running.\nPlease remove #{lock} if that is not the case."
    end

    File.open(lock, "w") do |f|
      f.write $$
    end
  end

  def unlock
    lock = File.join @dir, "lock"
    File.delete lock

    @ended_at = Time.now
  end
end
