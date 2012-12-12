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

  class RandomTask < Tube
    def run
      [ {:number => rand(10)}, {:number => rand(10)}]
    end
  end

  class RandomTaskStarter < Tube
    def run
      parallel do
        invoke RandomTask
        invoke RandomTask
      end
    end
  end

  class Task < Tube
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
    tube = Parallel::Task.new
    tube.run
    tube.output.should =~ [1, 2, 3, 4, 5, 'A', 'B', 'C', 'D', 'E']
  end

  it 'should retain symbolized keys of hashes' do
    tube = Parallel::RandomTaskStarter.new
    tube.run
    tube.output.each {|h| h.has_key?(:number).should be_true }
  end
end


