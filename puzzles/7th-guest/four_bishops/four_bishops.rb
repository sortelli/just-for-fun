#!/usr/bin/env ruby

board = {}

board[:a1] = [:b2, :c3, :d4]
board[:a2] = [:b1, :b3, :c4]
board[:a3] = [:b4, :b2, :c1]
board[:a4] = [:b3, :c2, :d1]

board[:b1] = [:a2, :c2, :d3, :e4]
board[:b2] = [:a1, :a3, :c1, :c3, :d4]
board[:b3] = [:a2, :a4, :c4, :c2, :d1]
board[:b4] = [:a3, :c3, :d2, :e1]

board[:c1] = [:b2, :a3, :d2, :e3]
board[:c2] = [:b1, :b3, :a4, :d1, :d3, :e4]
board[:c3] = [:b2, :a1, :b4, :d2, :e1, :d4]
board[:c4] = [:b3, :a2, :d3, :e2]

board[:d1] = [:c2, :b3, :a4, :e2]
board[:d2] = [:c1, :c3, :b4, :e1, :e3]
board[:d3] = [:c2, :b1, :c4, :e2, :c4]
board[:d4] = [:e3, :c3, :b2, :a1]

board[:e1] = [:d2, :c3, :b4]
board[:e2] = [:d1, :d3, :c4]
board[:e3] = [:d2, :d4, :c1]
board[:e4] = [:d3, :c2, :b1]

board[:blackPieces] = [:B1, :B2, :B3, :B4]
board[:whitePieces] = [:W1, :W2, :W3, :W4]
board[:pieces] = board[:blackPieces] + board[:whitePieces]
board[:enemies] = {
  :B1 => board[:whitePieces],
  :B2 => board[:whitePieces],
  :B3 => board[:whitePieces],
  :B4 => board[:whitePieces],
  :W1 => board[:blackPieces],
  :W2 => board[:blackPieces],
  :W3 => board[:blackPieces],
  :W4 => board[:blackPieces]
}

startingContext = {
  :moves => [],
  :state => {
    :B1 => :a1,
    :B2 => :a2,
    :B3 => :a3,
    :B4 => :a4,
    :W1 => :e1,
    :W2 => :e2,
    :W3 => :e3,
    :W4 => :e4
  }
}

def isSolved(context, board)
  context[:state].values_at(*board[:blackPieces]).sort == [:e1, :e2, :e3, :e4].sort && \
  context[:state].values_at(*board[:whitePieces]).sort == [:a1, :a2, :a3, :a4].sort
end

def print_move(move)
  puts("Move %s from %s to %s" % [move[:piece], move[:from], move[:to]])
end

def legalMoves(context, board, prevState)
  moves = []

  board[:pieces].map do |p|
    occupied = board[:pieces].map {|a| context[:state][a]} 
    illegal = occupied + board[:enemies][p].map {|a| board[context[:state][a]]}.flatten

    (board[context[:state][p]] - illegal).each do |m|
      newState    = context[:state].dup
      fromSquare  = newState[p]
      toSquare    = m
      newState[p] = toSquare
      stateKey    = newState.keys.sort.map {|k| newState[k]}.join(",")

      unless prevState.has_key?(stateKey)
        moves << {:piece => p, :from => fromSquare, :to => toSquare}
        prevState[stateKey] = true
      end
    end
  end

  moves
end

def nextMove(context, board, prevState)
  legalMoves(context, board, prevState).map do |m|
    newContext = context.dup
    newContext[:moves] = newContext[:moves].dup << m
    newContext[:state] = newContext[:state].merge(m[:piece] => m[:to])
    
    newContext
  end
end

contexts  = [[startingContext]]
prevState = {}

loop do
  puts("Checking for solutions that take %2d moves. %5d new board states" % [
    contexts.length - 1,
    contexts.last.length
  ])

  contexts.last.each do |c|
    if isSolved(c, board)
      puts "\nSolved"
      c[:moves].each {|m| print_move(m)}
      exit 0
    end
  end

  contexts.push(contexts.last.map {|c| nextMove(c, board, prevState)}.flatten)

  raise "wtf, didn't solve it" if contexts.last.size == 0
end
