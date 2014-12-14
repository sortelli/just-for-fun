#!/usr/bin/env ruby

require 'bfs_brute_force'
require 'set'

# Puzzle:
#
#  Seperate green and red books. Can only
#  move books in pairs.
#
# Inital layout:
#
#  +----+----+----+----+----+----+----+----+----+----+
#  | R1 | G1 | R2 | G2 | R3 | G3 | R4 | G4 |    |    |
#  +----+----+----+----+----+----+----+----+----+----+
#    0    1    2    3    4    5    6    7    8    9

class BooksState < BfsBruteForce::State
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
solver.solve BooksState.new
