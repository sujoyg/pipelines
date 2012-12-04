require 'json'
require 'monitor'

class Tube
  attr :dir
  attr :ended_at
  attr :exception
  attr :name
  attr :order
  attr :input
  attr :output
  attr :started_at
  attr :stats
  attr :thread_lock
  attr :threads

  def initialize(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    dir = args.first

    @dir = dir
    @type = options.delete(:type) || :serial
    @parent = options.delete(:parent) # This is nil only for the top level tube.

    @serial_count = 0
    @parallel_count = 0

    @thread_lock = @parent ? @parent.thread_lock : Monitor.new
    @stats = @parent ? @parent.stats : {}

    @name = underscore self.class.name.split('::')[-1]
    @order = options.delete(:order) || ''

    @input = options.delete(:input)
    @output = serial? ? nil : []

    @threads = []
    Thread.abort_on_exception = true

    @options = options
    @step = nil
    @ended_at = nil
    @started_at = options[:started_at] || Time.now
    @invocations = 0

    unless @dir.nil?
      Dir.mkdir(@dir) unless Dir.exists?(@dir)
    end

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
   
    dir = File.join(@dir, "#{description(klass)}") unless @dir.nil?
    segment = klass.new dir, :order => @order, :parent => self

    output_file = segment_cache segment
    if output_file && File.exists?(output_file)
      self.puts "Skipping: #{@order}-#{@invocations}-#{segment.name}"
      output = JSON.load(File.read(output_file))["data"]

      if serial?
        @output = output
        @input = output
      elsif parallel?
        @thread_lock.synchronize do
          @output << output
        end
      end
    else
      self.puts "Running: #{segment.name}"

      if serial?
        dispatch(segment, output_file, *args)
        @input = @output
      elsif parallel?
        thread = Thread.new do
          dispatch(segment, output_file, *args)
        end
        @threads << thread
      end
    end
  end


  def description(klass)
    if @order.nil?
      "#{@invocations}-#{underscore(klass.name.split('::')[-1])}"
    else
      "#{@order}-#{@invocations}-#{underscore(klass.name.split('::')[-1])}"
    end
  end

  def puts(string='')
    @thread_lock.synchronize do
      unlocked_puts(string)
    end

    nil # Behave like Kernel.puts
  end


  def unlocked_puts(string='')
    if self.class == Tube
      Kernel.puts "\033[32m[#{@order}]\033[0m #{string}"
    else
      Kernel.puts "\033[32m[#{@order}]\033[0m\033[36m[#{@name}]\033[0m #{string}"
    end

    STDOUT.flush
  end

  private

  def serial?
    @type == :serial
  end

  def parallel?
    @type == :parallel
  end

  def tube(mode, args=nil, &block)
    begin
      if parallel? # When inside parallel.
        thread = Thread.new do
          tube = child(mode, args)
          tube.instance_eval &block
          tube.threads.each { |thread| thread.join } # Could be a parallel block inside a parallel block.
          @thread_lock.synchronize do
            @output << (mode == :parallel ? tube.output.flatten(1) : tube.output)
          end
        end
        @threads << thread
      elsif serial?
        tube = child(mode, args)
        tube.instance_eval &block
        tube.threads.each { |thread| thread.join }
        @output = (mode == :parallel ? tube.output.flatten(1) : tube.output)
        @input = @output
      end
    rescue Exception => e
      @exception = e
      notify
      raise
    end
  end

  def notify
    # This should be implemented in the subclasses.
  end

  def run
    # This should be implemented in the subclasses.
  end

  def run_with_args(segment, args, options)
    if args.empty?
      if @invocations > 1
        if options.present?
          segment.send :run, @input, options
        else
          segment.send :run, @input
        end
      else
        if options.present?
          segment.send :run, options
        else
          segment.send :run
        end
      end
    else
      if options.present?
      	segment.send :run, *args, options
      else
        segment.send :run, *args
      end
    end
  end

  def dispatch(segment, output_file, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}

    output = if segment.method(:run).arity > 0 # Optional arguments result in negative arity.
               run_with_args(segment, args, options)
             elsif segment.method(:run).arity < 0
               run_with_args(segment, args, options)
             else
               segment.send :run
             end

    if output_file
      File.open(output_file, "w") do |f|
        f.write({:data => output}.to_json)
      end
    end

    if serial?
      @output = output
    elsif parallel?
      @thread_lock.synchronize do
        @output << output
      end
    end
  end


  def segment_cache(segment)
    File.join(@dir, "#{description(segment.class)}.json") if segment.dir
  end


  def child(type, args=nil)
    order = if type == :serial
              @serial_count += 1
              "#{@order}S#{@serial_count}"
            elsif type == :parallel
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
    return if @dir.nil?

    lock = File.join @dir, 'lock'
    if !@options[:force] && File.exists?(lock)
      raise "Another instance of the tubes seems to be running.\nPlease remove #{lock} if that is not the case."
    end

    File.open(lock, 'w') do |f|
      f.write $$
    end
  end

  def unlock
    unless @dir.nil?
      lock = File.join @dir, 'lock'
      File.delete lock
    end

    @ended_at = Time.now
  end

  def set_stats(values)
    @thread_lock.synchronize do 
      @stats[@name] = values
    end
  end

  def get_stats
    @thread_lock.synchronize do
      @stats[@name]
    end
  end
end
