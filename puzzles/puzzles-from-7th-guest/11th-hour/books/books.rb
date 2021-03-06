#!/usr/bin/env ruby

require 'bfs_brute_force'

# Puzzle:
#
# Separate green and red books. Can only
# move books in pairs.
#
# This is the "Books" puzzle from an old video game, The 11th Hour.
#
# Initial layout:
#
#  +---+---+---+---+---+---+---+---+---+---+
#  | R | G | R | G | R | G | R | G |   |   |
#  +---+---+---+---+---+---+---+---+---+---+
#    0   1   2   3   4   5   6   7   8   9
#
#       R = Red Book
#       G = Green Book

class BooksState < BfsBruteForce::State
  def initialize(books = nil)
    @books = books || [
      :R, :G, :R, :G,
      :R, :G, :R, :G,
      :_,  :_
    ]
  end

  def solved?
    @books == [
      :_, :_,
      :G, :G, :G, :G,
      :R, :R, :R, :R
    ] || @books == [
      :G, :G, :G, :G,
      :_, :_,
      :R, :R, :R, :R
    ] || @books == [
      :G, :G, :G, :G,
      :R, :R, :R, :R,
      :_, :_
    ]
  end

  def next_states(already_seen)
    empty_start = @books.index :_

    (@books.length - 1).times.each do |index|
      next if index == empty_start - 1 or index == empty_start

      book1, book2 = @books[index, 2]

      new_books = @books.dup

      new_books[empty_start]     = book1
      new_books[empty_start + 1] = book2

      new_books[index]     = :_
      new_books[index + 1] = :_

      if already_seen.add?(new_books)
        state = BooksState.new new_books
        move  = "Move #{index}.5 to #{empty_start}.5\n#{state}"
        yield move, state
      end
    end
  end

  def to_s
    fmt = %q{
      +---+---+---+---+---+---+---+---+---+---+
      | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |
      +---+---+---+---+---+---+---+---+---+---+
        0   1   2   3   4   5   6   7   8   9
    }

    fmt % @books.map {|s| s == :_ ? ' ' : s}
  end
end

solver = BfsBruteForce::Solver.new
moves  = solver.solve(BooksState.new).moves

puts moves
