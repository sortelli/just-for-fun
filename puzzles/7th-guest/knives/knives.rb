#!/usr/bin/env ruby

require 'bfs_brute_force'

# Puzzle:
#
# Remove all but one knife.
#
# Knives are initially arranged in a pentagram
#
#         0 
#        / \
#   1 - 3 - 4 - 2
#    \ /     \ /
#     5       6
#    /  \   /  \ 
#   /   / 7 \   \
#  /  _/     \_  \
#  8 /          \ 9
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
