#!/usr/bin/env ruby

require 'set'

##############################################################
# Inital Board layout
# Objective: Swap black and white knights
#
#    +----+----+----+----+----+
#  5 | BL | BL | BL | BL | WH |
#    +----+----+----+----+----+
#  4 | BL | BL | BL | WH | WH |
#    +----+----+----+----+----+   BL = Black Knight
#  3 | BL | BL |    | WH | WH |   WH = WHite Knight
#    +----+----+----+----+----+
#  2 | BL | BL | WH | WH | WH |
#    +----+----+----+----+----+
#  1 | BL | WH | WH | WH | WH |
#    +----+----+----+----+----+
#      a    b    c    d    e
#
##############################################################

legal_moves = {
  :a1 => [:b3, :c2],
  :a2 => [:b4, :c1, :c3],
  :a3 => [:b1, :b5, :c2, :c4],
  :a4 => [:b2, :c3, :c5],
  :a5 => [:b3, :c4],
  :b1 => [:a3, :c3, :d2],
  :b2 => [:a4, :c4, :d1, :d3],
  :b3 => [:a1, :a5, :c1, :c5, :d2, :d4],
  :b4 => [:a2, :c2, :d3, :d5],
  :b5 => [:a3, :c3, :d4],
  :c1 => [:a2, :b3, :d3, :e2],
  :c2 => [:a1, :a3, :b4, :d4, :e1, :e3],
  :c3 => [:a2, :a4, :b1, :b5, :d1, :d5, :e2, :e4],
  :c4 => [:a3, :a5, :b2, :d2, :e3, :e5],
  :c5 => [:a4, :b3, :d3, :e4],
  :d1 => [:e3, :c3, :b2],
  :d2 => [:e4, :c4, :b1, :b3],
  :d3 => [:e1, :e5, :c1, :c5, :b2, :b4],
  :d4 => [:e2, :c2, :b3, :b5],
  :d5 => [:e3, :c3, :b4],
  :e1 => [:d3, :c2],
  :e2 => [:d4, :c1, :c3],
  :e3 => [:d1, :d5, :c2, :c4],
  :e4 => [:d2, :c3, :c5],
  :e5 => [:d3, :c4]
}

def print_board(board)
  fmt = %Q{
     +----+----+----+----+----+
   5 | %2s | %2s | %2s | %2s | %2s |
     +----+----+----+----+----+
   4 | %2s | %2s | %2s | %2s | %2s |
     +----+----+----+----+----+
   3 | %2s | %2s | %2s | %2s | %2s |
     +----+----+----+----+----+
   2 | %2s | %2s | %2s | %2s | %2s |
     +----+----+----+----+----+
   1 | %2s | %2s | %2s | %2s | %2s |
     +----+----+----+----+----+
       a    b    c    d    e
  }

  indexes = [
    :a5, :b5, :c5, :d5, :e5,
    :a4, :b4, :c4, :d4, :e4,
    :a3, :b3, :c3, :d3, :e3,
    :a2, :b2, :c2, :d2, :e2,
    :a1, :b1, :c1, :d1, :e1
  ]

  puts(fmt % board.values_at(*indexes).map {|x| x || "  "})
end

legal_moves.each do |start, ends|
  board = ends.inject({start => 'X'}) do |h, e|
    h[e] = 'O'
    h
  end

  puts "Legal moves for #{start}"
  print_board board
end
