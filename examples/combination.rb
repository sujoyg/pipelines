#!/usr/bin/env ruby

require 'rubygems'
require 'pipelines'

class NumbersTask < Pipeline
  def run(first)
    last = first + 10
    (first..last).map do |i|
      puts i
      sleep 0.5
    end

    last
  end
end

class LettersTask < Pipeline
  def run(first)
    last = (first.ord + 10).chr
    (first..last).map do |i|
      puts i
      sleep 0.5
    end

    last
  end
end


class Tasks < Pipeline
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


if __FILE__ == $0
  pipeline = Tasks.new
  pipeline.run
end

