#!/usr/bin/env ruby

require 'rubygems'
require 'pipelines'

class NumbersTask < Pipeline
  def run
    (1..10).map do |i|
      puts i
      sleep 0.5
    end
  end
end

class LettersTask < Pipeline
  def run
    ('A'..'J').map do |char|
      puts char
      sleep 0.5
    end
  end
end


class Tasks < Pipeline
  def run
    parallel do
      invoke NumbersTask
      invoke LettersTask
    end      
  end
end


if __FILE__ == $0
  pipeline = Tasks.new
  pipeline.run
end

