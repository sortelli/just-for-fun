#!/usr/bin/env ruby

require 'bfs_brute_force'

# Puzzle:
#
# Place eight queens on a standard chess board, such that no queen
# can attack another queen.
#
# This is the "Eight Queens" puzzle from an old video game, The 7th Guest.
# This is also a classic chess puzzle found in lots of other places.

class BoardState < BfsBruteForce::State
  def initialize(board = nil)
    @board = board || [[:empty] * 8] * 8
  end

  def next_states(_)
    current_row, row_index = @board.each_with_index.find {|row, _| row.include?(:empty)}
    return if current_row.nil?

    current_row.each_with_index.select do |cell, _|
      cell == :empty
    end.each do |cell, cell_index|
      new_board = @board.dup.map {|row| row.dup}

      new_board[row_index] = [:blocked] * @board.length
      new_board.each_with_index do |row, index|
        row[cell_index] = :blocked
        offset = index - row_index

        if offset > 0
          left  = cell_index - offset
          right = cell_index + offset

          row[left]  = :blocked if left >= 0
          row[right] = :blocked if right < row.length
        end
      end
      new_board[row_index][cell_index] = :queen

      state = BoardState.new(new_board)
      yield state, state
    end
  end

  def solved?
    @board.all? {|row| row.include?(:queen)}
  end

  def to_s
    strings = @board.each_with_index.inject([]) do |strings, (row, index)|
      strings << '   +---+---+---+---+---+---+---+---+'
      strings << ' %d | %s |' % [8 - index, row.map {|c| c == :queen ? 'Q' : ' '}.join(' | ')]
    end

    strings << '   +---+---+---+---+---+---+---+---+'
    strings << '     A   B   C   D   E   F   G   H'

    strings.join("\n")
  end
end

solver = BfsBruteForce::Solver.new
moves  = solver.solve(BoardState.new).moves

puts moves.last
