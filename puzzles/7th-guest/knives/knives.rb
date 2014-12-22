#!/usr/bin/env ruby

require 'bfs_brute_force'

# Puzzle:
#
# Remove all but one knife.
#
# Knives are initially arranged in a pentagram, with
# only spot 0 being empty.
#
#         0
#        / \
#   1 - 2 - 3 - 4
#    \ /     \ /
#     5       6
#     / \ 7 / \
#     8 /   \ 9
#
#
# A knife can only move if it is immediately next to another knife,
# and can hop over that knife and land on an empty spot. This move
# will remove the knife that was hopped over (similar to checkers).
#
# This is the "Knife" puzzle from an old video game, The 7th Guest.

class KnivesState < BfsBruteForce::State
  @@moves = [
    {:from => 0, :to => 5, :jump => 2},
    {:from => 0, :to => 6, :jump => 3},
    {:from => 1, :to => 3, :jump => 2},
    {:from => 1, :to => 7, :jump => 5},
    {:from => 2, :to => 4, :jump => 3},
    {:from => 2, :to => 8, :jump => 5},
    {:from => 3, :to => 1, :jump => 2},
    {:from => 3, :to => 9, :jump => 6},
    {:from => 4, :to => 2, :jump => 3},
    {:from => 4, :to => 7, :jump => 6},
    {:from => 5, :to => 0, :jump => 2},
    {:from => 5, :to => 9, :jump => 7},
    {:from => 6, :to => 0, :jump => 3},
    {:from => 6, :to => 8, :jump => 7},
    {:from => 7, :to => 1, :jump => 5},
    {:from => 7, :to => 4, :jump => 6},
    {:from => 8, :to => 2, :jump => 5},
    {:from => 8, :to => 6, :jump => 7},
    {:from => 9, :to => 5, :jump => 7},
    {:from => 9, :to => 3, :jump => 6}
  ]

  def initialize(knives = nil)
    @knives = knives || [
      false, true, true, true, true, true, true, true, true, true
    ]
  end

  def solved?
    @knives.select {|k| k}.size == 1
  end

  def next_states(already_seen)
    @@moves.each.each do |move|
      new_knives = @knives.dup
      new_knives[move[:from]] = false
      new_knives[move[:jump]] = false
      new_knives[move[:to  ]] = true

      if already_seen.add?(new_knives)
        yield "Move knife #{move[:from]}", KnivesState.new(new_knives)
      end
    end
  end

  def to_s
    fmt = %q{
            %s
           / \
      %s - %s - %s - %s
       \ /     \ /
        %s       %s
        / \ %s / \
        %s /   \ %s
    }

    fmt % @knives.map {|k| k ? 'X' : 'O'}
  end
end

solver = BfsBruteForce::Solver.new
moves  = solver.solve(KnivesState.new).moves

puts moves
