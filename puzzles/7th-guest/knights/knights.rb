#!/usr/bin/env ruby

require 'set'

##############################################################
# Inital Board layout
# Objective: Swap black and white knights
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

legal_moves = {}

legal_moves[:a1] = [:b3, :c2]
legal_moves[:a2] = [:b4, :c1, :c3]
legal_moves[:a3] = [:b1, :b5, :c2, :c4]
legal_moves[:a4] = [:b2, :c3, :c5]
legal_moves[:a5] = [:b3, :c4]

legal_moves[:b1] = [:a3, :c3, :d2]
legal_moves[:b2] = [:a4, :c4, :d1, :d3]
legal_moves[:b3] = [:a1, :a5, :c1, :c5, :d2, :d4]
legal_moves[:b4] = [:a2, :c2, :d3, :d5]
legal_moves[:b5] = [:a3, :c3, :d4]

legal_moves[:c1] = [:a2, :b3, :d3, :e2]
legal_moves[:c2] = [:a1, :a3, :b4, :d4, :e1, :e3]
legal_moves[:c3] = [:a2, :a4, :b1, :b5, :d1, :d5, :e2, :e4]
legal_moves[:c4] = [:a3, :a5, :b2, :d2, :e3, :e5]
legal_moves[:c5] = [:a4, :b3, :d3, :e4]

legal_moves[:d1] = [:e3, :c3, :b2]
legal_moves[:d2] = [:e4, :c4, :b1, :b3]
legal_moves[:d3] = [:e1, :e5, :c1, :c5, :b2, :b4]
legal_moves[:d4] = [:e2, :c2, :b3, :b5]
legal_moves[:d5] = [:e3, :c3, :b4]

legal_moves[:e1] = [:d3, :c2]
legal_moves[:e2] = [:d4, :c1, :c3]
legal_moves[:e3] = [:d1, :d5, :c2, :c4]
legal_moves[:e4] = [:d2, :c3, :c5]
legal_moves[:e5] = [:d3, :c4]
