require File.expand_path '../spec_helper', __FILE__
require File.expand_path '../../lib/pipelines', __FILE__

module Serial
  class FirstTask < Pipeline
    def run
      (1..10).to_a.reverse
    end
  end

  class SecondTask < Pipeline
    def run(input)
      input.map { |i| i * 2 }
    end
  end


  class Task < Pipeline
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
    pipeline = Serial::Task.new
    pipeline.run
    pipeline.output.should == [20, 18, 16, 14, 12, 10, 8, 6, 4, 2]
  end
end

