require File.expand_path '../spec_helper', __FILE__
require File.expand_path '../../lib/tubes', __FILE__

module Combination
  class NumbersTask < Tube
    def run(first)
      first + 10
    end
  end

  class LettersTask < Tube
    def run(first)
      (first.ord + 10).chr
    end
  end


  class Task < Tube
    def run
      parallel do
        serial do
          invoke NumbersTask, 1
          invoke NumbersTask
        end

        serial do
          invoke LettersTask, 'A'
          invoke LettersTask
        end
      end      
    end
  end
end


describe Combination::Task do
  it 'should run.' do
    tube = Combination::Task.new
    tube.run
    tube.output.should =~ [21, 'U']
  end
end

