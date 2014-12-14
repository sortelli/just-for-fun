#!/usr/bin/env ruby

require 'bfs_brute_force'

# Puzzle:
#
#   Swap white and black knights, using standard chess moves.
#
# Inital layout:
#
#    +----+
#  4 | BK |
#    +----+----+----+----+
#  3 |    |    |    | WK |
#    +----+----+----+----+
#  2 | BK | WK |    |
#    +----+----+----+
#  1 |    |    |
#    +----+----+
#      a    b    c    d

class KnightsState < BfsBruteForce::State
  def initialize
  end

  def solved?
    true
  end

  def next_states(already_seen)
  end

  def to_s
  end
end

solver = BfsBruteForce::Solver.new
solver.solve KnightsState.new
