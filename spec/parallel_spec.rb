require File.expand_path '../spec_helper', __FILE__
require File.expand_path '../../lib/pipelines', __FILE__

module Parallel
  class NumbersTask < Pipeline
    def run
      (1..5).to_a
    end
  end

  class LettersTask < Pipeline
    def run
      ('A'..'E').to_a
    end
  end


  class Task < Pipeline
    def run
      parallel do
        invoke NumbersTask
        invoke LettersTask
      end
    end
  end
end


describe Parallel::Task do
  it 'should run.' do
    pipeline = Parallel::Task.new
    pipeline.run
    pipeline.output.should =~ [1, 2, 3, 4, 5, 'A', 'B', 'C', 'D', 'E']
  end
end


