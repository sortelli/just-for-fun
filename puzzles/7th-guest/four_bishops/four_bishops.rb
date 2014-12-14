#!/usr/bin/env ruby

require 'bfs_brute_force'
require 'set'

# Puzzle:
#
#  Swap black and white bishops, following
#  standard chess movement rules.
#
# Inital Board layout:
#
#    +----+----+----+----+----+
#  4 | B4 |    |    |    | W4 |
#    +----+----+----+----+----+
#  3 | B3 |    |    |    | W3 |
#    +----+----+----+----+----+
#  2 | B2 |    |    |    | W2 |
#    +----+----+----+----+----+
#  1 | B1 |    |    |    | W1 |
#    +----+----+----+----+----+
#      a    b    c    d    e

class FourBishopsState < BfsBruteForce::State
  @@moves = {
    :a1 => [:b2, :c3, :d4],
    :a2 => [:b1, :b3, :c4],
    :a3 => [:b2, :b4, :c1],
    :a4 => [:b3, :c2, :d1],
    :b1 => [:a2, :c2, :d3, :e4],
    :b2 => [:a1, :a3, :c1, :c3, :d4],
    :b3 => [:a2, :a4, :c2, :c4, :d1],
    :b4 => [:a3, :c3, :d2, :e1],
    :c1 => [:a3, :b2, :d2, :e3],
    :c2 => [:a4, :b1, :b3, :d1, :d3, :e4],
    :c3 => [:a1, :b2, :b4, :d2, :d4, :e1],
    :c4 => [:a2, :b3, :d3, :e2],
    :d1 => [:a4, :b3, :c2, :e2],
    :d2 => [:b4, :c1, :c3, :e1, :e3],
    :d3 => [:b1, :c2, :c4, :c4, :e2],
    :d4 => [:a1, :b2, :c3, :e3],
    :e1 => [:b4, :c3, :d2],
    :e2 => [:c4, :d1, :d3],
    :e3 => [:c1, :d2, :d4],
    :e4 => [:b1, :c2, :d3]
  }

  @@black_bishops = [:B1, :B2, :B3, :B4]
  @@white_bishops = [:W1, :W2, :W3, :W4]
  @@all_bishops   = @@black_bishops + @@white_bishops

  @@enemies = {}
  @@black_bishops.each {|bp| @@enemies[bp] = Set.new(@@white_bishops)}
  @@white_bishops.each {|wp| @@enemies[wp] = Set.new(@@black_bishops)}

  def initialize(position = nil)
    @position = position || {
      :B1 => :a1, :B2 => :a2, :B3 => :a3, :B4 => :a4,
      :W1 => :e1, :W2 => :e2, :W3 => :e3, :W4 => :e4
    }
  end

  def solved?
    @position.values_at(*@@black_bishops).sort == [:e1, :e2, :e3, :e4] && \
    @position.values_at(*@@white_bishops).sort == [:a1, :a2, :a3, :a4]
  end

  def next_states(already_seen)
    occupied = @@all_bishops.map {|b| @position[b]}

    @@all_bishops.each do |bishop|
      illegal = occupied + @@enemies[bishop].flat_map {|b| @@moves[@position[b]]}

      (@@moves[@position[bishop]] - illegal).each do |to_square|
        from_square  = @position[bishop]
        new_position = @position.merge(bishop => to_square)
        state_key    = new_position.keys.sort.map {|k| new_position[k]}.join(",")

        if already_seen.add?(state_key)
          move = "Move #{bishop} from #{from_square} to #{to_square}"
          yield move, FourBishopsState.new(new_position)
        end
      end
    end
  end

  def to_s
    fmt = %Q{
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

    bishops = @position.inject({}) do |h, (k, v)|
      h[v] = k
      h
    end

    pieces = @@moves.keys.inject({}) do |h, k|
      h[k] = bishops[k]
      h
    end

    fmt % pieces.values_at(
      :a4, :b4, :c4, :d4, :e4,
      :a3, :b3, :c3, :d3, :e3,
      :a2, :b2, :c2, :d2, :e2,
      :a1, :b1, :c1, :d1, :e1
    )
  end
end

solver = BfsBruteForce::Solver.new
solver.solve FourBishopsState.new

# Running this will produce the following output:
#
# % ./four_bishops.rb
# Looking for solution for:
#
#         +----+----+----+----+----+
#       4 | B4 |    |    |    | W4 |
#         +----+----+----+----+----+
#       3 | B3 |    |    |    | W3 |
#         +----+----+----+----+----+
#       2 | B2 |    |    |    | W2 |
#         +----+----+----+----+----+
#       1 | B1 |    |    |    | W1 |
#         +----+----+----+----+----+
#           a    b    c    d    e
#
#
# Checking for solutions that take    1 moves ... none in         8 new states
# Checking for solutions that take    2 moves ... none in        29 new states
# Checking for solutions that take    3 moves ... none in        56 new states
# Checking for solutions that take    4 moves ... none in        87 new states
# Checking for solutions that take    5 moves ... none in       165 new states
# Checking for solutions that take    6 moves ... none in       362 new states
# Checking for solutions that take    7 moves ... none in       668 new states
# Checking for solutions that take    8 moves ... none in      1027 new states
# Checking for solutions that take    9 moves ... none in      1448 new states
# Checking for solutions that take   10 moves ... none in      2104 new states
# Checking for solutions that take   11 moves ... none in      3059 new states
# Checking for solutions that take   12 moves ... none in      4166 new states
# Checking for solutions that take   13 moves ... none in      5244 new states
# Checking for solutions that take   14 moves ... none in      6263 new states
# Checking for solutions that take   15 moves ... none in      7246 new states
# Checking for solutions that take   16 moves ... none in      7938 new states
# Checking for solutions that take   17 moves ... none in      8021 new states
# Checking for solutions that take   18 moves ... none in      7977 new states
# Checking for solutions that take   19 moves ... none in      8401 new states
# Checking for solutions that take   20 moves ... none in      9303 new states
# Checking for solutions that take   21 moves ... none in      9996 new states
# Checking for solutions that take   22 moves ... none in     10121 new states
# Checking for solutions that take   23 moves ... none in      9954 new states
# Checking for solutions that take   24 moves ... none in      9479 new states
# Checking for solutions that take   25 moves ... none in      8451 new states
# Checking for solutions that take   26 moves ... none in      6995 new states
# Checking for solutions that take   27 moves ... none in      5647 new states
# Checking for solutions that take   28 moves ... none in      5092 new states
# Checking for solutions that take   29 moves ... none in      4868 new states
# Checking for solutions that take   30 moves ... none in      4246 new states
# Checking for solutions that take   31 moves ... none in      3418 new states
# Checking for solutions that take   32 moves ... none in      2804 new states
# Checking for solutions that take   33 moves ... none in      2240 new states
# Checking for solutions that take   34 moves ... none in      1485 new states
# Checking for solutions that take   35 moves ... none in       832 new states
# Checking for solutions that take   36 moves ... solved in 159339 tries
#
# Moves:
#   Move B2 from a2 to b3
#   Move B3 from a3 to b2
#   Move W1 from e1 to b4
#   Move W2 from e2 to d3
#   Move B2 from b3 to d1
#   Move W2 from d3 to c4
#   Move W3 from e3 to d2
#   Move B3 from b2 to d4
#   Move W1 from b4 to a3
#   Move W3 from d2 to c1
#   Move B1 from a1 to c3
#   Move B1 from c3 to e1
#   Move B3 from d4 to c3
#   Move W3 from c1 to e3
#   Move W1 from a3 to c1
#   Move B3 from c3 to b4
#   Move W1 from c1 to b2
#   Move W3 from e3 to d4
#   Move B3 from b4 to d2
#   Move W1 from b2 to a3
#   Move W3 from d4 to a1
#   Move B3 from d2 to e3
#   Move W4 from e4 to b1
#   Move W4 from b1 to a2
#   Move B2 from d1 to c2
#   Move B2 from c2 to e4
#   Move B4 from a4 to c2
#   Move W2 from c4 to e2
#   Move W4 from a2 to c4
#   Move B4 from c2 to b1
#   Move W2 from e2 to d1
#   Move W2 from d1 to a4
#   Move W4 from c4 to b3
#   Move B4 from b1 to d3
#   Move B4 from d3 to e2
#   Move W4 from b3 to a2
#
# Final state:
#
#         +----+----+----+----+----+
#       4 | W2 |    |    |    | B2 |
#         +----+----+----+----+----+
#       3 | W1 |    |    |    | B3 |
#         +----+----+----+----+----+
#       2 | W4 |    |    |    | B4 |
#         +----+----+----+----+----+
#       1 | W3 |    |    |    | B1 |
#         +----+----+----+----+----+
#           a    b    c    d    e
