require File.expand_path '../spec_helper', __FILE__
require File.expand_path '../../lib/tubes', __FILE__

module Parallel
  class NumbersTask < Tube
    def run
      (1..5).to_a
    end
  end

  class LettersTask < Tube
    def run
      ('A'..'E').to_a
    end
  end


  class Task < Tube
    def run
      parallel do
        invoke NumbersTask
        invoke LettersTask
      end
      return ['respect','run','return','value']
    end
  end
end


describe Parallel::Task do
  it 'should run.' do
    tube = Parallel::Task.new
    tube.run
    tube.output.should =~ [1, 2, 3, 4, 5, 'A', 'B', 'C', 'D', 'E']
  end

  it 'should respect the return value of Tube.run' do
    Parallel::Task.new.run.should == ['respect','run','return','value']
  end
end


