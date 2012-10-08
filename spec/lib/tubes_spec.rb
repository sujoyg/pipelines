require File.expand_path '../../spec_helper', __FILE__
require File.expand_path '../../../lib/tubes', __FILE__

describe Tube do
  describe '#initialize' do
    it 'creates a directory if specified.' do
      Dir.should_not exist '/foo'
      Tube.new '/foo', :type => :serial
      Dir.should exist '/foo'
    end

    it 'does not create any directory if not specified.' do
      Dir['/*'].should be_empty
      Tube.new :type => :parallel
      Dir['/*'].should be_empty
    end
  end

  describe '#tube' do
    context 'when in parallel mode' do
      let(:tube) { Tube.new :type => :parallel }

      [:serial, :parallel].each do |mode|
        it "should create a thread when launching a #{mode} child tube." do
          threads = []

          tube.send(:tube, mode) { threads << Thread.current }
          tube.threads.each { |t| t.join }

          threads.first.should_not == Thread.current
        end
      end
    end

    context 'when in serial mode' do
      let(:tube) { Tube.new :type => :serial }

      [:serial, :parallel].each do |mode|
        it "should not create a thread when launching a #{mode} child tube." do
          threads = []

          tube.send(:tube, mode) { threads << Thread.current }
          tube.threads.each { |t| t.join }

          threads.first.should == Thread.current
        end
      end
    end
  end

  describe '#serial?' do
    it 'should be true for a serial tube.' do
      tube = Tube.new :type => :serial
      tube.should be_serial
    end

    it 'should be false for a parallel tube.' do
      tube = Tube.new :type => :parallel
      tube.should_not be_serial
    end
  end

  describe '#parallel?' do
    it 'should be false for a serial tube.' do
      tube = Tube.new :type => :serial
      tube.should_not be_parallel
    end

    it 'should be true for a parallel tube.' do
      tube = Tube.new :type => :parallel
      tube.should be_parallel
    end
  end
end