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

  def initialize(start_knights, end_knights, nil_index = nil)
    @knights     = start_knights
    @end_knights = end_knights
    @nil_index   = nil_index || @knights.index(:nn)
    raise "Illegal board layout" unless @knights.size == 25
  end

  def next_states(already_seen)
    @@legal_moves_to_square[@nil_index].each do |start_index|
      new_knights = @knights.dup
      temp = new_knights[start_index]
      new_knights[start_index] = new_knights[@nil_index]
      new_knights[@nil_index] = temp

      if already_seen.add?(new_knights)
        move  = "#{start_index} to #{@nil_index}"
        board = Board.new(new_knights, @end_knights, start_index)

        yield move, board
      end
    end
  end

  def solved?
    @knights == @end_knights
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

    fmt % @knights
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

solver = BfsBruteForce::Solver.new
moves  = solver.solve(Board.new(start_knights, end_knights), $stderr).moves

puts moves
