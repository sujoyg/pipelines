#!/usr/bin/env ruby

require 'rubygems'
require 'pipelines'

class FirstTask < Pipeline
  def run
    output = []

    (1..10).map do |i|
      puts i
      sleep 0.5
      output << i      
    end

    # This output is used as an input to any following task.
    output.reverse
  end
end

class SecondTask < Pipeline
  def run(input)
    input.each do |i|
      puts i
      sleep 0.5
    end
  end
end


class Tasks < Pipeline
  def run
    serial do
      invoke FirstTask
      invoke SecondTask
    end      
  end
end


if __FILE__ == $0
  pipeline = Tasks.new
  pipeline.run
end

