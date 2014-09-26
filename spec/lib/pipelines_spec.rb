require File.expand_path '../../spec_helper', __FILE__
require File.expand_path '../../../lib/pipelines', __FILE__

describe Pipeline do
  describe '#initialize' do
    it 'creates a directory if specified.' do
      Dir.should_not exist '/foo'
      Pipeline.new '/foo', :type => :serial
      Dir.should exist '/foo'
    end

    it 'does not create any directory if not specified.' do
      Dir['/*'].should be_empty
      Pipeline.new :type => :parallel
      Dir['/*'].should be_empty
    end
  end

  describe '#pipeline' do
    context 'when in parallel mode' do
      let(:pipeline) { Pipeline.new :type => :parallel }

      [:serial, :parallel].each do |mode|
        it "should create a thread when launching a #{mode} child pipeline." do
          threads = []

          pipeline.send(:pipeline, mode) { threads << Thread.current }
          pipeline.threads.each { |t| t.join }

          threads.first.should_not == Thread.current
        end
      end
    end

    context 'when in serial mode' do
      let(:pipeline) { Pipeline.new :type => :serial }

      [:serial, :parallel].each do |mode|
        it "should not create a thread when launching a #{mode} child pipeline." do
          threads = []

          pipeline.send(:pipeline, mode) { threads << Thread.current }
          pipeline.threads.each { |t| t.join }

          threads.first.should == Thread.current
        end
      end
    end
  end

  describe '#serial?' do
    it 'should be true for a serial pipeline.' do
      pipeline = Pipeline.new :type => :serial
      pipeline.should be_serial
    end

    it 'should be false for a parallel pipeline.' do
      pipeline = Pipeline.new :type => :parallel
      pipeline.should_not be_serial
    end
  end

  describe '#parallel?' do
    it 'should be false for a serial pipeline.' do
      pipeline = Pipeline.new :type => :serial
      pipeline.should_not be_parallel
    end

    it 'should be true for a parallel pipeline.' do
      pipeline = Pipeline.new :type => :parallel
      pipeline.should be_parallel
    end
  end
end