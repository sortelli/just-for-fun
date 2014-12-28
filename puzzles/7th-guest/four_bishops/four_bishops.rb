#!/usr/bin/env ruby

require 'bfs_brute_force'

# Puzzle:
#
# Swap black and white bishops, following standard chess movement
# rules, except that bishops may not move to a square that would allow
# them to be captured by an enemy bishop (they may not put themselves
# in "check").
#
# This is the "Four Bishops" puzzle from an old video game, The 7th Guest.
#
# Initial Board layout:
#
#       +----+----+----+----+----+
#     4 | BB |    |    |    | WB |
#       +----+----+----+----+----+
#     3 | BB |    |    |    | WB |
#       +----+----+----+----+----+
#     2 | BB |    |    |    | WB |
#       +----+----+----+----+----+
#     1 | BB |    |    |    | WB |
#       +----+----+----+----+----+
#         a    b    c    d    e
#
#     BB = Black Bishop
#     WB = White Bishop

class FourBishopsState < BfsBruteForce::State
  # Legal moves: from_position => [to_position, ...]
  @@moves = {
    :A1 => [:B2, :C3, :D4],
    :A2 => [:B1, :B3, :C4],
    :A3 => [:B2, :B4, :C1],
    :A4 => [:B3, :C2, :D1],
    :B1 => [:A2, :C2, :D3, :E4],
    :B2 => [:A1, :A3, :C1, :C3, :D4],
    :B3 => [:A2, :A4, :C2, :C4, :D1],
    :B4 => [:A3, :C3, :D2, :E1],
    :C1 => [:A3, :B2, :D2, :E3],
    :C2 => [:A4, :B1, :B3, :D1, :D3, :E4],
    :C3 => [:A1, :B2, :B4, :D2, :D4, :E1],
    :C4 => [:A2, :B3, :D3, :E2],
    :D1 => [:A4, :B3, :C2, :E2],
    :D2 => [:B4, :C1, :C3, :E1, :E3],
    :D3 => [:B1, :C2, :C4, :C4, :E2],
    :D4 => [:A1, :B2, :C3, :E3],
    :E1 => [:B4, :C3, :D2],
    :E2 => [:C4, :D1, :D3],
    :E3 => [:C1, :D2, :D4],
    :E4 => [:B1, :C2, :D3]
  }

  def initialize(bishops = nil)
    # State of the board: position => bishop
    @bishops = bishops || {
      :A1 => :BB, :A2 => :BB, :A3 => :BB, :A4 => :BB,
      :E1 => :WB, :E2 => :WB, :E3 => :WB, :E4 => :WB
    }
  end

  # (see BfsBruteForce::State#solved)
  def solved?
    @bishops == {
      :A1 => :WB, :A2 => :WB, :A3 => :WB, :A4 => :WB,
      :E1 => :BB, :E2 => :BB, :E3 => :BB, :E4 => :BB
    }
  end

  # Yield all not previously seen states from the current state
  # (see BfsBruteForce::State#already_seen)
  def next_states(already_seen)
    @bishops.each do |from, bishop|
      enemy   = bishop == :WB ? :BB : :WB
      illegal = @bishops.select {|_, b| b == enemy}.flat_map {|p, _| @@moves[p]}

      @@moves[from].reject do |to|
        # Skip illegal positions
        @bishops[to] or illegal.include?(to)
      end.each do |to|
        new_bishops = @bishops.merge(to => bishop)
        new_bishops.delete from

        if already_seen.add?(new_bishops)
          state = FourBishopsState.new new_bishops
          move  = "Move #{bishop} from #{from} to #{to}\n#{state}"
          yield move, state
        end
      end
    end
  end

  def to_s
    fmt = %Q{
        +----+----+----+----+----+
      4 | %s | %s | %s | %s | %s |
        +----+----+----+----+----+
      3 | %s | %s | %s | %s | %s |
        +----+----+----+----+----+
      2 | %s | %s | %s | %s | %s |
        +----+----+----+----+----+
      1 | %s | %s | %s | %s | %s |
        +----+----+----+----+----+
          a    b    c    d    e
    }
    fmt % [
      :A4, :B4, :C4, :D4, :E4,
      :A3, :B3, :C3, :D3, :E3,
      :A2, :B2, :C2, :D2, :E2,
      :A1, :B1, :C1, :D1, :E1
    ].map {|index| @bishops[index] || '  '}
  end
end

solver = BfsBruteForce::Solver.new
moves  = solver.solve(FourBishopsState.new).moves

puts moves
