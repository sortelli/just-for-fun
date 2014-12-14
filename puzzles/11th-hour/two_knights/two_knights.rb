#!/usr/bin/env ruby

require 'bfs_brute_force'

# Puzzle:
#
#   Swap white and black knights, using standard chess moves.
#
# Inital layout:
#
#    +----+
#  4 | BK |
#    +----+----+----+----+
#  3 |    |    |    | WK |
#    +----+----+----+----+
#  2 | BK | WK |    |
#    +----+----+----+
#  1 |    |    |
#    +----+----+
#      a    b    c    d

class KnightsState < BfsBruteForce::State
  @@moves = {
    :a1 => [:b3, :c2],
    :a2 => [:c3],
    :a3 => [:b1, :c2],
    :a4 => [:b2, :c3],
    :b1 => [:a3, :c3],
    :b2 => [:a4, :d3],
    :b3 => [:a1],
    :c2 => [:a1, :a3],
    :c3 => [:a2, :a4, :b1],
    :d3 => [:b2]
  }

  def initialize(knights = nil)
    @knights = knights || {
      :a2 => :BK,
      :a4 => :BK,
      :b2 => :WK,
      :d3 => :WK
    }
  end

  def solved?
    @knights == {
      :a2 => :WK,
      :a4 => :WK,
      :b2 => :BK,
      :d3 => :BK
    }
  end

  def next_states(already_seen)
    @knights.flat_map do |(from, knight)|
      @@moves[from].reject {|to| @knights[to]}.map {|to| [from, to, knight]}
    end.each do |from, to, knight|
      new_knights = @knights.merge(to => knight)
      new_knights.delete from

      if already_seen.add?(new_knights)
        state = KnightsState.new new_knights
        move  = "Move #{knight} from #{from} to #{to}\n#{state}"
        yield move, state
      end
    end
  end

  def to_s
    fmt = %q{
        +----+
      4 | %s |
        +----+----+----+----+
      3 | %s | %s | %s | %s |
        +----+----+----+----+
      2 | %s | %s | %s |
        +----+----+----+
      1 | %s | %s |
        +----+----+
          a    b    c    d
    }

    fmt % [:a4, :a3, :b3, :c3, :d3, :a2, :b2, :c2, :a1, :b1].map do |index|
      @knights[index] || '  '
    end
  end
end

solver = BfsBruteForce::Solver.new
solver.solve KnightsState.new
