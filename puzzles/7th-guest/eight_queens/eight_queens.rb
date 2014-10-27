#!/usr/bin/env ruby

def copy_board(board)
  board.dup.map {|r| r.dup}
end

def print_board(board)
  board.each do |r|
    puts r.join(" ")
  end
end

def remove_invalid(board, parent_col)
  board.each {|r| r[parent_col] = '.'}
  board.each_with_index do |r, i|
    x = parent_col + i + 1
    y = parent_col - i - 1

    r[x] = '.' if x < r.length
    r[y] = '.' if y >= 0
  end
end

def place_queen(board)
  return nil if board.nil? or board.empty?
  return nil unless board.first.find {|c| c == '-'}

  row = board.shift
  orig_row   = row.dup
  orig_board = copy_board board

  row.each_with_index do |c, i|
    if c == '-'
      row[i] = 'Q'

      return [row] if board.empty?
 
      board = copy_board orig_board
      remove_invalid board, i

      if b = place_queen(board)
        row.each_with_index {|c, i| row[i] = '.' if c == '-'}
        return b.unshift(row)       
      end

      row[i] = '-'
    end 
  end

  return nil
end

empty_board = copy_board([['-'] * 8] * 8)
board = place_queen empty_board
print_board board
