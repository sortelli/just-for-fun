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
#   1 - 3 - 4 - 2
#    \ /     \ /
#     5       6
#    /  \ 7 /  \
#    8 /     \ 9
#
#
# A knife can only move if it is immediately next to another knife,
# and can hop over that knife and land on an empty spot. This move
# will remove the knife that was hopped over (similar to checkers).
#
# This is the "Knife" puzzle from an old video game, The 7th Guest.

class KnivesState < BfsBruteForce::State
  def initialize(knives)
    @knives = knives
  end

  def solved?
    false
  end

  def next_states(already_seen)
  end
end
