# Overview

`Pipelines` is simple way to build a pipeline of tasks. These tasks can be configured to run in serial, parallel or any combination thereof.

# Examples
## Parallel Tasks
```ruby
require 'rubygems'
require 'pipelines'

class NumbersTask < Pipeline
  def run
    (1..10).each do |i|
      puts i
      sleep 0.5
    end
  end
end

class LettersTask < Pipeline
  def run
    ('A'..'J').each do |char|
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
```
## Serial Tasks
```ruby
class FirstTask < Pipeline
  def run
    # Do something
  end
end

class SecondTask < Pipeline
  def run
    # Do something
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
```

## Combo Task

```ruby
class NumbersTask < Pipeline
  def run(start)
    # Do something
  end
end

class LettersTask < Pipeline
  def run(start)
    # Do something
  end
end


class Tasks < Pipeline
  def run
    parallel do
      serial do
        invoke NumbersTask
        invoke NumbersTask
      end

      serial do
        invoke LettersTask
        invoke LettersTask
      end
    end      
  end
end


if __FILE__ == $0
  pipeline = Tasks.new
  pipeline.run
end
```
