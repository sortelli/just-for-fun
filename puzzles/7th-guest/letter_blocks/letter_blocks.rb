#!/usr/bin/env ruby

require 'bfs_brute_force'

# Puzzle:
#
# Shift blocks to correct orientation.
#
# The board is divided into a 3x3 grid of lettered blocks.
#
# Initial Layout:
#
#       +---+---+---+
#     3 | D | A | T |
#       +---+---+---+
#     2 | Y | O | B |
#       +---+---+---+
#     1 | T | E | G |
#       +---+---+---+
#         A   B   C
#
# Blocks can be shifted forward or backwards a row or column at a
# time.
#
# The puzzle is solved when the blocks are in this order:
#
#       +---+---+---+
#     3 | G | E | T |
#       +---+---+---+
#     2 | B | O | Y |
#       +---+---+---+
#     1 | T | A | D |
#       +---+---+---+
#         A   B   C
#
# This is the "Letter Blocks" puzzle from an old video game, The 7th Guest.

class LetterBlocksState < BfsBruteForce::State
  @@directions   = [:forward, :backward]
  @@word_indexes = {
    :horizontalTop    => [0, 1, 2],
    :horizontalMiddle => [3, 4, 5],
    :horizontalBottom => [6, 7, 8],
    :verticalLeft     => [0, 3, 6],
    :verticalMiddle   => [1, 4, 7],
    :verticalRight    => [2, 5, 8]
  }

  def initialize(blocks = nil)
    @blocks = blocks || %w{
      D A T
      Y O B
      T E G
    }
    raise "Illegal board layout" unless @blocks.size == 9
  end

  def shift_blocks(direction, indexes)
    blocks = @blocks.dup
    word   = blocks.values_at(*indexes)

    case direction
      when :forward
        word.unshift word.pop
      when :backward
        word.push word.shift
      else
        raise "Unknown direction: #{direction}"
    end

    indexes.zip(word).each do |(index, block)|
      blocks[index] = block
    end

    blocks
  end

  def next_states(already_seen)
    @@word_indexes.each do |(name, indexes)|
      @@directions.each do |direction|
        new_blocks = shift_blocks direction, indexes

        if already_seen.add?(new_blocks)
          state = LetterBlocksState.new new_blocks
          move  = "%s%s\n%s" % [name, direction.capitalize, state]

          yield move, state
        end
      end
    end
  end

  def solved?
    @blocks == %w{
      G E T
      B O Y
      T A D
    }
  end

  def to_s
    %q{
       +---+---+---+
     3 | %s | %s | %s |
       +---+---+---+
     2 | %s | %s | %s |
       +---+---+---+
     1 | %s | %s | %s |
       +---+---+---+
         A   B   C
    } % @blocks
  end
end

solver = BfsBruteForce::Solver.new
moves  = solver.solve(LetterBlocksState.new).moves

puts moves
