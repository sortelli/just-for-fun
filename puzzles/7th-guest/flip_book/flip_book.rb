#!/usr/bin/env ruby

require 'set'

# Card layout:
#
# 0 1 2
# 3 4 5
# 6 7 8

class Card
  def initialize(value)
    @value = value.to_i
    raise "Card value (#{value}) must be >= 0 and < 9" unless (0..8).include?(@value)
  end

  def next
    Card.new((@value + 1) % 9)
  end

  def prev
    Card.new((@value - 1) % 9)
  end

  def hash
    @value.hash
  end

  def to_s
    @value.to_s
  end

  def to_i
    @value
  end
end


class Board
  @@possible_moves = {
    :horizontalTopLeft     => [:next, 0, 1, 2],
    :horizontalTopRight    => [:prev, 0, 1, 2],
    :horizontalMiddleLeft  => [:next, 3, 4, 5],
    :horizontalMiddleRight => [:prev, 3, 4, 5],
    :horizontalBottomLeft  => [:next, 6, 7, 8],
    :horizontalBottomRight => [:prev, 6, 7, 8],
    :verticalLeftUp        => [:next, 0, 3, 6],
    :verticalLeftDown      => [:prev, 0, 3, 6],
    :verticalMiddleUp      => [:next, 1, 4, 7],
    :verticalMiddleDown    => [:prev, 1, 4, 7],
    :verticalRightUp       => [:next, 2, 5, 8],
    :verticalRightDown     => [:prev, 2, 5, 8]
  }.inject({}) do |moves, (k, v)|
    moves[k] = {
      v[1] => v[0],
      v[2] => v[0],
      v[3] => v[0]
    }
    moves
  end

  def initialize(layout, prev_state = Set.new)
    @prev_state = prev_state
    @cards      = layout.map {|c| Card.new(c)}
    raise "Illegal board layout" unless @cards.size == 9
  end

  def next_moves(moves)
    @@possible_moves.map do |move_name, move_functions|
      new_cards = (0..8).map do |index|
        case
          when move_functions.has_key?(index)
            @cards[index].send(move_functions[index])
          else
            @cards[index]
        end
      end

      next nil if @prev_state.include?(new_cards)
      @prev_state.add new_cards

      {:moves => moves + [move_name], :board => Board.new(new_cards, @prev_state)}
    end.compact
  end

  def hash
    @cards.hash
  end

  def solved?
    @cards.map {|c| c.to_i} == (0..8).to_a
  end

  def inspect
    "<\n  %s %s %s\n  %s %s %s\n  %s %s %s\n>" % @cards
  end
end

def solve(start_cards)
  start_board = Board.new start_cards
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

starting_cards = (0..8).map do |index|
  print "Enter card at position #{index}: "
  $stdin.gets.to_i
end

solve starting_cards
