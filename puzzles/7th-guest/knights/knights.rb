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
  @@indexes = [
    :a5, :b5, :c5, :d5, :e5,
    :a4, :b4, :c4, :d4, :e4,
    :a3, :b3, :c3, :d3, :e3,
    :a2, :b2, :c2, :d2, :e2,
    :a1, :b1, :c1, :d1, :e1
  ]

  @@legal_moves = {
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

  @@legal_moves_to_square = @@legal_moves.inject(Hash.new do |h, x|
    h[x] = []
  end) do |h, (start, ends)|
    ends.each do |end_index|
      h[end_index] << start
    end
    h
  end

  def initialize(start_knights, end_knights, nil_index = nil)
    @knights     = start_knights
    @end_knights = end_knights
    @nil_index   = nil_index || @knights.find {|_, v| v.nil?}[0]
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

    fmt % @knights.values_at(*@@indexes)
  end
end

start_knights = {
  :a1 => :BL, :a2 => :BL, :a3 => :BL, :a4 => :BL, :a5 => :BL,
  :b1 => :WH, :b2 => :BL, :b3 => :BL, :b4 => :BL, :b5 => :BL,
  :c1 => :WH, :c2 => :WH, :c3 => nil, :c4 => :BL, :c5 => :BL,
  :d1 => :WH, :d2 => :WH, :d3 => :WH, :d4 => :WH, :d5 => :BL,
  :e1 => :WH, :e2 => :WH, :e3 => :WH, :e4 => :WH, :e5 => :WH
}

end_knights = {
  :a1 => :WH, :a2 => :WH, :a3 => :WH, :a4 => :WH, :a5 => :WH,
  :b1 => :BL, :b2 => :WH, :b3 => :WH, :b4 => :WH, :b5 => :WH,
  :c1 => :BL, :c2 => :BL, :c3 => nil, :c4 => :WH, :c5 => :WH,
  :d1 => :BL, :d2 => :BL, :d3 => :BL, :d4 => :BL, :d5 => :WH,
  :e1 => :BL, :e2 => :BL, :e3 => :BL, :e4 => :BL, :e5 => :BL
}

=begin
end_knights = {
  :a1 => :BL, :a2 => :BL, :a3 => :BL, :a4 => :BL, :a5 => :BL,
  :b1 => :WH, :b2 => :BL, :b3 => :BL, :b4 => :BL, :b5 => :BL,
  :c1 => :WH, :c2 => :WH, :c3 => :WH, :c4 => :BL, :c5 => :BL,
  :d1 => :WH, :d2 => :WH, :d3 => :WH, :d4 => :WH, :d5 => nil,
  :e1 => :WH, :e2 => :WH, :e3 => :BL, :e4 => :WH, :e5 => :WH
}
=end

solver = BfsBruteForce::Solver.new
moves  = solver.solve(Board.new(start_knights, end_knights), $stderr).moves

puts moves
