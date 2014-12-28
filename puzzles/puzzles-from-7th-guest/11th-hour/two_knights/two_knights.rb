#!/usr/bin/env ruby

require 'bfs_brute_force'

# Puzzle:
#
# Swap the white and black knights, using standard chess moves.
#
# This is the "Two Knights" puzzle from an old video game, The 11th Hour.
#
# Initial board layout:
#
#       +----+
#     4 | BK |
#       +----+----+----+----+
#     3 |    |    |    | WK |
#       +----+----+----+----+
#     2 | BK | WK |    |
#       +----+----+----+
#     1 |    |    |
#       +----+----+
#         A    B    C    D
#
#     BK = Black Knight
#     WK = White Knight

class KnightsState < BfsBruteForce::State
  # Legal moves: from_position => [to_position, ...]
  @@moves = {
    :A1 => [:B3, :C2],
    :A2 => [:C3],
    :A3 => [:B1, :C2],
    :A4 => [:B2, :C3],
    :B1 => [:A3, :C3],
    :B2 => [:A4, :D3],
    :B3 => [:A1],
    :C2 => [:A1, :A3],
    :C3 => [:A2, :A4, :B1],
    :D3 => [:B2]
  }

  def initialize(knights = nil)
    # State of the board: position => knight
    @knights = knights || {
      :A2 => :BK,
      :A4 => :BK,
      :B2 => :WK,
      :D3 => :WK
    }
  end

  # (see BfsBruteForce::State#solved)
  def solved?
    @knights == {
      :A2 => :WK,
      :A4 => :WK,
      :B2 => :BK,
      :D3 => :BK
    }
  end

  # Yield all not previously seen states from the current state
  # (see BfsBruteForce::State#next_states)
  def next_states(already_seen)
    @knights.each do |from, knight|
      @@moves[from].reject do |to|
        # Skip occupied positions
        @knights[to]
      end.each do |to|
        new_knights = @knights.merge(to => knight)
        new_knights.delete from

        if already_seen.add?(new_knights)
          state = KnightsState.new new_knights
          move  = "Move #{knight} from #{from} to #{to}\n#{state}"
          yield move, state
        end
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
          A    B    C    D
    }

    fmt % [:A4, :A3, :B3, :C3, :D3, :A2, :B2, :C2, :A1, :B1].map do |index|
      @knights[index] || '  '
    end
  end
end

solver = BfsBruteForce::Solver.new
moves  = solver.solve(KnightsState.new).moves

puts moves
