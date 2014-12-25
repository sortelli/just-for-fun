#!/usr/bin/env ruby

##############################################################
# Objective: Swap black and white knights
# Inital Board layout:
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

require 'bfs_brute_force'

class Board
  @@legal_moves_to_square = [
    [7, 11],
    [8, 10, 12],
    [5, 9, 11, 13],
    [6, 12, 14],
    [7, 13],
    [2, 12, 16],
    [3, 13, 15, 17],
    [0, 4, 10, 14, 16, 18],
    [1, 11, 17, 19],
    [2, 12, 18],
    [1, 7, 17, 21],
    [0, 2, 8, 18, 20, 22],
    [1, 3, 5, 9, 15, 19, 21, 23],
    [2, 4, 6, 16, 22, 24],
    [3, 7, 17, 23],
    [6, 12, 22],
    [5, 7, 13, 23],
    [6, 8, 10, 14, 20, 24],
    [7, 9, 11, 21],
    [8, 12, 22],
    [11, 17],
    [10, 12, 18],
    [11, 13, 15, 19],
    [12, 14, 16],
    [13, 17]
  ]

  @@bitmap_index = (0..24).map {|i| 1 << i}
  @@label_index = [
    :a5, :b5, :c5, :d5, :e5,
    :a4, :b4, :c4, :d4, :e4,
    :a3, :b3, :c3, :d3, :e3,
    :a2, :b2, :c2, :d2, :e2,
    :a1, :b1, :c1, :d1, :e1
  ]

  def self.from_array(start_knights_array, end_knights_array)
    array_to_bitmap = lambda do |array|
      bitmap = array.each_with_index.inject(0) do |s, (k, i)|
        s | (k == :WH ? @@bitmap_index[i] : 0)
      end

      [array.index(:nn), bitmap]
    end

    start_nil_index, start_knights = array_to_bitmap.call start_knights_array
    end_nil_index,   end_knights   = array_to_bitmap.call end_knights_array

    Board.new(start_knights, start_nil_index, end_knights, end_nil_index)
  end

  def initialize(knights, nil_index, end_knights, end_nil_index)
    @knights       = knights
    @nil_index     = nil_index
    @end_knights   = end_knights
    @end_nil_index = end_nil_index
  end

  def next_states(already_seen)
    @@legal_moves_to_square[@nil_index].each do |start_index|
      is_white = (@knights & @@bitmap_index[start_index]) > 0

      new_knights = if is_white
        (@knights | @@bitmap_index[@nil_index]) & ~(@@bitmap_index[start_index])
      else
        @knights
      end

     if already_seen.add?((start_index * 1000000000) + new_knights)
       move  = "#{@@label_index[start_index]} to #{@@label_index[@nil_index]}"
       board = Board.new(new_knights, start_index, @end_knights, @end_nil_index)

       yield move, board
     end
    end
  end

  def solved?
    @nil_index == @end_nil_index && @knights == @end_knights
  end

  def to_s
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

    board = (0..24).map {|i| (@knights & @@bitmap_index[i]) > 0 ? :WH : :BL}
    board[@nil_index] = nil

    fmt % board
  end
end

start_knights = [
  :BL, :BL, :BL, :BL, :WH,
  :BL, :BL, :BL, :WH, :WH,
  :BL, :BL, :nn, :WH, :WH,
  :BL, :BL, :WH, :WH, :WH,
  :BL, :WH, :WH, :WH, :WH
]

end_knights = [
  :WH, :WH, :WH, :WH, :BL,
  :WH, :WH, :WH, :BL, :BL,
  :WH, :WH, :nn, :BL, :BL,
  :WH, :WH, :BL, :BL, :BL,
  :WH, :BL, :BL, :BL, :BL
]

start  = Board.from_array(start_knights, end_knights)
solver = BfsBruteForce::Solver.new
moves  = solver.solve(start, $stdout).moves

puts moves
