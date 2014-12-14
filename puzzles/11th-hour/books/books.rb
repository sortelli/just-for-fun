#!/usr/bin/env ruby

require 'bfs_brute_force'

# Puzzle:
#
#  Seperate green and red books. Can only
#  move books in pairs.
#
# Inital layout:
#
#  +---+---+---+---+---+---+---+---+---+---+
#  | R | G | R | G | R | G | R | G |   |   |
#  +---+---+---+---+---+---+---+---+---+---+
#    0   1   2   3   4   5   6   7   8   9

class BooksState < BfsBruteForce::State
  def initialize(books = nil)
    @books = books || [
      :R, :G,
      :R, :G,
      :R, :G,
      :R, :G,
      :_,  :_
    ]
  end

  def solved?
    @books == [
      :R, :R,
      :R, :R,
      :_, :_,
      :G, :G,
      :G, :G
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
        new_state = BooksState.new new_books
        yield "Move #{index}.5 to #{empty_start}.5\n#{new_state}", new_state
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
solver.solve BooksState.new
