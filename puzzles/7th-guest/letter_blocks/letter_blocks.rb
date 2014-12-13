#!/usr/bin/env ruby

require 'bundler/setup'
require 'bfs_brute_force'
require 'set'

class LetterBlocksContext < BfsBruteForce::Context
  @@directions   = [:forward, :backward]
  @@word_indexes = {
    :horizontalTop    => [0, 1, 2],
    :horizontalMiddle => [3, 4, 5],
    :horizontalBottom => [6, 7, 8],
    :verticalLeft     => [0, 3, 6],
    :verticalMiddle   => [1, 4, 7],
    :verticalRight    => [2, 5, 8]
  }

  def initialize(blocks, end_blocks)
    @blocks     = blocks
    @end_blocks = end_blocks
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

  def next_moves(already_seen)
    @@word_indexes.each do |(name, indexes)|
      @@directions.each do |direction|
        new_blocks = shift_blocks direction, indexes

        if already_seen.add?(new_blocks)
          yield "#{name}#{direction.capitalize}", LetterBlocksContext.new(new_blocks, @end_blocks)
        end
      end
    end
  end

  def solved?
    @blocks == @end_blocks
  end

  def to_s
    "<Board\n  %s %s %s\n  %s %s %s\n  %s %s %s\n>" % @blocks
  end
end

initial_blocks = %w{
  D A T
  Y O B
  T E G
}

final_blocks = %w{
  G E T
  B O Y
  T A D
}

solver = BfsBruteForce::Solver.new
solver.solve(LetterBlocksContext.new(initial_blocks, final_blocks))
