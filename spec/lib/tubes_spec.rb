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