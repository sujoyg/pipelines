require File.expand_path '../spec_helper', __FILE__
require File.expand_path '../../lib/tubes', __FILE__

module Serial
  class FirstTask < Tube
    def run
      (1..10).to_a.reverse
    end
  end

  class SecondTask < Tube
    def run(input)
      input.map { |i| i * 2 }
    end
  end

  class RandomTask < Tube
    def run
      [ {:number => rand(10)}, {:number => rand(10)}]
    end
  end

  class RandomTaskStarter < Tube
    def run
      serial do
        invoke RandomTask
        invoke RandomTask
      end
    end
  end

  class Task < Tube
    def run
      serial do
        invoke FirstTask
        invoke SecondTask
      end      
    end
  end
end


describe Serial::Task do
  it 'should run.' do
    tube = Serial::Task.new
    tube.run
    tube.output.should == [20, 18, 16, 14, 12, 10, 8, 6, 4, 2]
  end

  it 'should retain symbolized keys of hashes' do
    tube = Parallel::RandomTaskStarter.new
    tube.run
    tube.output.each {|h| h.has_key?(:number).should be_true }
  end
end

