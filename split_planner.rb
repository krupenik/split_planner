#! /usr/bin/env ruby

Days = 14
Groups = 5
Workouts = [50, 50, 75, 100]
Intervals = [2, 2..3, 3..4, 3..Days]
DaysOff = [5, 12]

class Schedule
  @@rendered = 0
  
  attr_accessor :schedule
  
  def initialize schedule=nil
    @schedule = schedule || Array.new(Groups) { Array.new(Workouts.size) }
    @group = 0
    @workout = 0
  end
  
  def plan
    backtrack and return if [-1, Groups].include? @group
    backtrack and return if [-1, Workouts.size].include? @workout

    Days.times do |day|
      next if @schedule[@group].include? day
      next if DaysOff.include? day
      
      set day

      if valid?
        render if complete?
        advance
        plan
      else
        reset
      end
    end

    reset
    backtrack
  end
  
  def set day
    @schedule[@group][@workout] = day
  end
  
  def reset
    @schedule[@group][@workout] = nil
  end
  
  def advance
    @workout += 1
    
    if Workouts.size == @workout
      @group += 1
      @workout = 0
    end
  end
  
  def backtrack
    @workout -= 1
    
    if -1 == @workout
      @workout = Workouts.size - 1
      @group -= 1
    end
  end
  
  def complete?
    @schedule.map.all? { |group| group.index(nil) == nil }
  end
  
  def valid?
    [
      valid_intervals?,
      valid_days?,
    ].flatten.all?
  end
  
  def valid_intervals?
    @schedule.map { |group| valid_group_intervals? group }
  end
  
  def valid_group_intervals? group
    Intervals.size.times.all? { |i| valid_interval?(group, i) }
  end
  
  def valid_interval? group, index
    [group[index], group[(index+1) % Intervals.size]].include?(nil) ||
    (Intervals[index] === ((group[(index+1)%Intervals.size] - group[index]) % Days))
  end
    
  def valid_days?
    Days.times.all? { |day|
      workouts = @schedule.map { |group| group.index(day) }.compact.map { |i| Workouts[i] }
      [100] == workouts || (nil == workouts.index(100) && workouts.reduce(0, :+) <= 175)
    }
  end
  
  def render
    @@rendered += 1
    
    puts "* ##{@@rendered}"
    Days.times { |day|
      puts "%02d: %s" % [day,
        Groups.times.map { |group|
          index = @schedule[group].index(day)
          "% 4d" % (index ? Workouts[index] : 0)
        }.join(" | ")
      ]
    }
    puts "-"*(6*(Groups+1))
  end
end
  
Schedule.new.plan
