#!/usr/bin/env ruby

require 'rubygems'
require 'tubes'

class NumbersTask < Tube
  def run
    (1..10).map do |i|
      i
    end
  end
end

class LettersTask < Tube
  def run
    ('A'..'J').map do |char|
      char
    end
  end
end


class Tasks < Tube
  def run
    parallel do
      invoke NumbersTask
      invoke LettersTask
    end
    puts "output of tasks was automatically assigned: #{output}"
  end
end


if __FILE__ == $0
  tube = Tasks.new
  tube.run
end

