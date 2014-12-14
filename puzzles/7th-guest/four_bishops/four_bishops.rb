#!/usr/bin/env ruby

require 'bfs_brute_force'
require 'set'

# Objective: Swap black and white bishops
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
    :a3 => [:b4, :b2, :c1],
    :a4 => [:b3, :c2, :d1],
    :b1 => [:a2, :c2, :d3, :e4],
    :b2 => [:a1, :a3, :c1, :c3, :d4],
    :b3 => [:a2, :a4, :c4, :c2, :d1],
    :b4 => [:a3, :c3, :d2, :e1],
    :c1 => [:b2, :a3, :d2, :e3],
    :c2 => [:b1, :b3, :a4, :d1, :d3, :e4],
    :c3 => [:b2, :a1, :b4, :d2, :e1, :d4],
    :c4 => [:b3, :a2, :d3, :e2],
    :d1 => [:c2, :b3, :a4, :e2],
    :d2 => [:c1, :c3, :b4, :e1, :e3],
    :d3 => [:c2, :b1, :c4, :e2, :c4],
    :d4 => [:e3, :c3, :b2, :a1],
    :e1 => [:d2, :c3, :b4],
    :e2 => [:d1, :d3, :c4],
    :e3 => [:d2, :d4, :c1],
    :e4 => [:d3, :c2, :b1]
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
    @@all_bishops.each do |bishop|
      occupied = @@all_bishops.map {|b| @position[b]}
      illegal  = occupied + @@enemies[bishop].flat_map {|b| @@moves[@position[b]]}

      (@@moves[@position[bishop]] - illegal).each do |to_square|
        from_square  = @position[bishop]
        new_position = @position.merge(bishop => to_square)
        state_key    = new_position.keys.sort.map {|k| new_position[k]}.join(",")

        if already_seen.add?(state_key)
          yield "Move #{bishop} from #{from_square} to #{to_square}", FourBishopsState.new(new_position)
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
