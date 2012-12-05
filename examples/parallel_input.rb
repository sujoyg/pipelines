#!/usr/bin/env ruby

require 'rubygems'
require 'tubes'

class NumbersTask < Tube
  def run(numbers)
    numbers.each do |i|
      puts i * 2
      sleep 0.5
    end
  end
end

class LettersTask < Tube
  def run(characters)
    characters.each do |char|
      puts "#{char}#{char}"
      sleep 0.5
    end
  end
end


class Tasks < Tube
  def run
    parallel do
      invoke NumbersTask, [2, 4, 6, 8]
      invoke LettersTask, ['c', 'h', 'a', 'n', 'g', 'e', 's']
    end
  end
end


if __FILE__ == $0
  tube = Tasks.new
  tube.run
end

