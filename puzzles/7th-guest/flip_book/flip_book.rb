#!/usr/bin/env ruby

# Card layout:
#
# 0 1 2
# 3 4 5
# 6 7 8

class Card
  def initialize(value)
    @value = value
    raise "bad value" unless (0..8).include?(value)
  end

  def next
    Card.new((@value + 1) % 9)  
  end

  def prev
    Card.new((@value - 1) % 9)  
  end
end
