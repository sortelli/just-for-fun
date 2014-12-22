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
#     3 | F3 | F3 | F2 |
#       +----+----+----+
#     2 | F3 | F3 | F3 |
#       +----+----+----+
#     1 | F3 | F3 | F3 |
#       +----+----+----+
#         A    B    C

class Card
  attr_reader :face

  def initialize(face)
    @face = face
  end

  def flip
    next_face = case @face
      when :F1 then :F2
      when :F2 then :F3
      else          :F1
    end

    Card.new next_face
  end

  def ==(other)
    @face == other.face
  end

  def hash
    @face.hash
  end

  alias :eql? :==

  def to_s
    @face.to_s
  end
end

class PortraitState < BfsBruteForce::State
  @@solution = [Card.new(:F1)] * 9
  # Board indexed in follow card order: A3,B3,C3,A2,B2,C2,A1,B1,C1
  @@labels = %w{
    A3 B3 C3
    A2 B2 C2
    A1 B1 C1
  }
  @@flips = [
    [0, 1, 3, 4],
    [0, 1, 2],
    [1, 2, 4, 5],
    [0, 3, 6],
    [0, 2, 4, 6, 8],
    [2, 5, 8],
    [3, 4, 6, 7],
    [6, 7, 8],
    [4, 5, 7, 8]
  ]

  def initialize(cards)
    @cards = cards
  end

  def solved?
    @cards == @@solution
  end

  def next_states(already_seen)
    @@flips.each_with_index do |flip, flipped_index|
      next_cards = @cards.each_with_index.map do |card, index|
        flip.include?(index) ? card.flip : card
      end

      if already_seen.add?(next_cards)
        yield "Flip #{@@labels[flipped_index]}\n#{self}", PortraitState.new(next_cards)
      end
    end
  end

  def to_s
    %q{
       +----+----+----+
     3 | %2s | %2s | %2s |
       +----+----+----+
     2 | %2s | %2s | %2s |
       +----+----+----+
     1 | %2s | %2s | %2s |
       +----+----+----+
         A    B    C
    } % @cards
  end
end

unless ARGV.size == 0 or ARGV.size == 9
  $stderr.puts "usage: #{File.basename(__FILE__)} (A3 B3 C3 A2 B2 C2 A1 B1 C1)"
  exit 1
end

values = case
  when ARGV.size == 9 && ARGV.all? {|a| ("F1".."F3").include?(a)}
    ARGV
  when ARGV.size == 0
    %w{F3 F3 F2 F3 F3 F3 F3 F3 F3}
  else
    raise "The value of each card labeled [A-C][1-3] must be one of: F1 or F2 or F3"
end

cards  = values.map {|v| Card.new(v)}
solver = BfsBruteForce::Solver.new
moves  = solver.solve(PortraitState.new(cards)).moves

puts moves
