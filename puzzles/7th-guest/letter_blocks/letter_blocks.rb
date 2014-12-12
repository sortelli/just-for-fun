#!/usr/bin/env ruby

require 'set'

# Initial block layout
#
# D A T
# Y O B
# T E G

class Board
  @@directions   = [:forward, :backward]
  @@word_indexes = {
    :horizontalTop    => [0, 1, 2],
    :horizontalMiddle => [3, 4, 5],
    :horizontalBottom => [6, 7, 8],
    :verticalLeft     => [0, 3, 6],
    :verticalMiddle   => [1, 4, 7],
    :verticalRight    => [2, 5, 8]
  end

  def initialize(blocks, legal_words, prev_state = Set.new)
    @blocks      = blocks
    @legal_words = legal_words
    @prev_state  = prev_state
    raise "Illegal board layout" unless @blocks.size == 9
  end

  def new_board(new_blocks)
    Board.new(new_blocks, @legal_words, @prev_state)
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

  def next_moves(prev_moves)
    @@word_indexes.inject({}) do |moves, (name, indexes)|
      @@directions.each do |direction|
        new_blocks = shift_blocks direction, indexes

        unless @prev_state.include? move
          @prev_state.add move
          moves.push({
            :moves => moves + ["#{name}#{direction.capitalize}"],
            :board => new_board(new_blocks),
          })
        end
      end

      moves
    end
  end

  def solved?
    @@word_indexes.values.all? do |indexes|
      word = '%s%s%s' % @blocks.values_at(*indexes)
      @legal_words.include?(word)
    end
  end

  def inspect
    "<\n  %s %s %s\n  %s %s %s\n  %s %s %s\n>" % @blocks
  end
end

def solve(legal_words, start_blocks)
  start_board = Board.new start_blocks, legal_words
  puts "Looking for solution for #{start_board.inspect}"

  contexts = [[{:moves => [], :board => start_board}]]

  loop do
    puts("Checking for solutions that take %3d moves. %5d new board states" % [
      contexts.length - 1,
      contexts.last.length
    ])

    contexts.last.each do |context|
      if context[:board].solved?
        puts "\nSolved:\n"
        puts context[:moves].map {|m| "  #{m}"}
        exit 0
      end
    end

    contexts.push(contexts.last.map {|c| c[:board].next_moves(c[:moves])}.flatten)

    raise "wtf, didn't solve it" if contexts.last.size == 0
  end
end

initial_blocks = %w{
  D A T
  Y O B
  T E G
}

legal_words = Set.new

File.open('three_letter_words.txt', 'r') do |file|
  while line = file.gets
    legal_words.add(line.chomp)
  end
end

solve legal_words, inital_blocks
