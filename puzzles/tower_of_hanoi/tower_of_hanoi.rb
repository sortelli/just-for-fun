#!/usr/bin/env ruby

require 'bfs_brute_force'

# Puzzle: Tower of Hanoi
#
# Description: http://en.wikipedia.org/wiki/Tower_of_Hanoi

class TowersState < BfsBruteForce::State
  def self.initial_state(num_of_disks = 7, num_of_rods = 3)
    towers    = (0...num_of_rods).map { [] }
    towers[0] = (1..num_of_disks).to_a.reverse
    solution  = towers[0]

    TowersState.new towers, solution
  end

  def initialize(towers, solution)
    @towers   = towers
    @solution = solution
  end

  def solved?
    @towers.last == @solution
  end

  def next_states(already_seen)
    @towers.each_with_index do |tower, curr_index|
      (0...@towers.size).each do |next_index|
        curr_disk = tower.last
        next_disk = @towers[next_index].last

        next if curr_index == next_index
        next if curr_disk.nil?
        next if !next_disk.nil? && next_disk < tower.last

        new_towers = @towers.map {|t| t.dup}
        new_towers[curr_index].pop
        new_towers[next_index].push curr_disk
        new_state = TowersState.new new_towers, @solution

        if already_seen.add?(new_towers)
          yield "Move #{curr_index} to #{next_index}\n#{new_state}", new_state
        end
      end
    end
  end

  def to_s
    out = []

    @towers.each_with_index do |tower, index|
      out.push('%2d: %s' % [index, tower.inspect])
    end

    out.join "\n"
  end
end

if ARGV.size > 2
  $stderr.puts "usage: #{File.basename(__FILE__)} [num_of_disks] [num_of_rods]"
  exit 1
end

solver = BfsBruteForce::Solver.new
moves  = solver.solve(TowersState.initial_state(*ARGV.map {|a| a.to_i})).moves

puts moves
