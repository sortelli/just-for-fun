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
    :horizontalTop    => [0, 1, 2],
    :horizontalMiddle => [3, 4, 5],
    :horizontalBottom => [6, 7, 8],
    :verticalLeft     => [0, 3, 6],
    :verticalMiddle   => [1, 4, 7],
    :verticalRight    => [2, 5, 8]
  }.inject({}) do |moves, (k, v)|
    [
      {:name => "Right", :move => :next},
      {:name => "Left",  :move => :prev}
    ].each do |m|
      moves["#{k}#{m[:name]}".to_sym] = {
        v[0] => m[:move],
        v[1] => m[:move],
        v[2] => m[:move],
      }
    end

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

example_start = [
 1, 2, 4,
 3, 4, 6,
 6, 7, 0
]

contexts = [[{:moves => [], :board => Board.new(example_start)}]]

loop do
  puts("Checking for solutions that take %3d moves. %5d new board states" % [
    contexts.length - 1,
    contexts.last.length
  ])

  contexts.last.each do |context|
    if context[:board].solved?
      puts "\nSolved"
      puts context[:moves]
      exit 0
    end
  end

  contexts.push(contexts.last.flatMap {|c| c[:board].next_moves(c[:moves])})

  raise "wtf, didn't solve it" if contexts.last.size == 0
end
