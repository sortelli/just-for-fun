#!/usr/bin/env ruby

require 'bfs_brute_force'

# Puzzle:
#
# Flip cards to correct orientation.
#
# Board is divided into a 3x3 grid of cards, which are labeled A1
# to A3, B1 to B3, C1 to C3.
#
#       +----+----+----+
#     3 | A3 | B3 | C3 |
#       +----+----+----+
#     2 | A2 | B2 | C2 |
#       +----+----+----+
#     1 | A1 | B1 | C1 |
#       +----+----+----+
#         A    B    C
#
# Each card has three sides or faces, and can be flipped in one
# direction.  We'll label the three faces of each card F1, F2, and
# F3.  Flipping a card will transitions the faces as follows:
#
#     F1 -> F2
#     F2 -> F3
#     F3 -> F1
# 
# Flipping a card will also flip some of the cards it is next to,
# using the following rules:
#
#     Flipping A1 also flips: A2, B1, B2
#     Flipping A2 also flips: A1, A3
#     Flipping A3 also flips: A2, B2, B3
#     Flipping B1 also flips: A1, C1
#     Flipping B2 also flips: A1, A3, C1, C3
#     Flipping B3 also flips: A3, C3
#     Flipping C1 also flips: B1, B2, C2
#     Flipping C2 also flips: C1, C3
#     Flipping C3 also flips: B2, B3, C2
#
# The puzzle is solved when all nine cards are showing face F1.
#
# This is the "Stauf's Portrait" puzzle from an old video game, The 7th Guest.
#
# In the video game, the initial board layout is random. This program
# will accept the board layout from the command line, or default
# to a static default initial layout.
#
# Default Initial Layout:
#
#       +----+----+----+
#     3 | F3 | F1 | F3 |
#       +----+----+----+
#     2 | F2 | F2 | F1 |
#       +----+----+----+
#     1 | F1 | F1 | F2 |
#       +----+----+----+
#         A    B    C

class PortraitState < BfsBruteForce::State
  def initialize(cards)
    @cards = cards
  end

  def solved?
    false
  end

  def next_states(already_seen)
  end
end
