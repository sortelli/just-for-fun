#!/usr/bin/env ruby

require 'bfs_brute_force'

# Puzzle:
#
# Flip cards to correct orientation.
#
# The board is divided into a 3x3 grid of cards, which are labeled
# A1 to A3, B1 to B3, C1 to C3.
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
# Each card has nine consecutive sides or faces, and can be flipped
# forward or backwards.  We'll label the nine faces of each card
# F1 - F9.  Flipping a card forward or backwards will increase or
# decrease respectively the value of the card by one, modulo nine.
#
# When flipping a card forward or backwards, all cards in the same
# row or column must also flip in the same direction.
#
# The puzzle is solved when all nine cards are in order:
#
#       +----+----+----+
#     3 | F1 | F2 | F3 |
#       +----+----+----+
#     2 | F4 | F5 | F6 |
#       +----+----+----+
#     1 | F7 | F8 | F9 |
#       +----+----+----+
#         A    B    C
#
# This is the "Picture" puzzle from an old video game, The 7th Guest.
#
# In the video game, the initial board layout is random. This program
# will accept the board layout from the command line, or default
# to a static default initial layout.
#
# Default Initial Layout:
#
#       +----+----+----+
#     3 | F2 | F3 | F4 |
#       +----+----+----+
#     2 | F4 | F5 | F7 |
#       +----+----+----+
#     1 | F7 | F8 | F1 |
#       +----+----+----+
#         A    B    C

class BoardState < BfsBruteForce::State
  @@flip_prev = lambda {|card| (card - 1) % 9}
  @@flip_next = lambda {|card| (card + 1) % 9}

  @@identity_moves = (0..8).inject({}) do |move, index|
    move[index] = lambda {|card| card}
    move
  end

  @@possible_moves = {
    :horizontalTopLeft     => [@@flip_next, 0, 1, 2],
    :horizontalTopRight    => [@@flip_prev, 0, 1, 2],
    :horizontalMiddleLeft  => [@@flip_next, 3, 4, 5],
    :horizontalMiddleRight => [@@flip_prev, 3, 4, 5],
    :horizontalBottomLeft  => [@@flip_next, 6, 7, 8],
    :horizontalBottomRight => [@@flip_prev, 6, 7, 8],
    :verticalLeftUp        => [@@flip_next, 0, 3, 6],
    :verticalLeftDown      => [@@flip_prev, 0, 3, 6],
    :verticalMiddleUp      => [@@flip_next, 1, 4, 7],
    :verticalMiddleDown    => [@@flip_prev, 1, 4, 7],
    :verticalRightUp       => [@@flip_next, 2, 5, 8],
    :verticalRightDown     => [@@flip_prev, 2, 5, 8]
  }.inject({}) do |moves, (k, v)|
    moves[k] = @@identity_moves.merge({
      v[1] => v[0],
      v[2] => v[0],
      v[3] => v[0]
    })
    moves
  end

  def initialize(cards)
    @cards = cards
    raise "Illegal board layout" unless @cards.size == 9
  end

  def next_states(already_seen)
    @@possible_moves.each do |move_name, move_functions|
      new_cards = (0..8).map do |index|
        move_functions[index].call(@cards[index])
      end

      if already_seen.add?(new_cards)
        state = BoardState.new(new_cards)
        move  = "%s\n%s" % [move_name, state]

        yield move, state
      end
    end
  end

  def solved?
    @cards.map {|c| c.to_i} == (0..8).to_a
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
    } % @cards.map {|card| "F#{card + 1}"}
  end
end

unless ARGV.size == 0 or ARGV.size == 9
  $stderr.puts "usage: #{File.basename(__FILE__)} (A3 B3 C3 A2 B2 C2 A1 B1 C1)"
  exit 1
end

values = case
  when ARGV.size == 9 && ARGV.all? {|a| ("F1".."F9").include?(a)}
    ARGV
  when ARGV.size == 0
    %w{F2 F3 F5 F5 F6 F8 F8 F9 F2}
  else
    raise "The value of each card labeled [A-C][1-3] must be one of: F1-F9"
end

cards  = values.map {|v| v[/\d/].to_i - 1}
solver = BfsBruteForce::Solver.new
moves  = solver.solve(BoardState.new(cards)).moves

puts moves
