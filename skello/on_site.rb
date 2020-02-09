# frozen_string_literal: true

require "bundler/inline"
require 'inline'
require "minitest/autorun"

# Question on site :
# https://leetcode.com/problems/min-stack/

class MinStack
  def initialize()
    @stack, @min = [], []
  end

  def push(value)
    if value <= (@min[-1] || Float::INFINITY)
      @min.push(value)
    end
    @stack.push(value)
  end

  def pop()
    if @stack[-1] == @min[-1]
      @min.pop()
    end
    @stack.pop()
  end

  def min(); @min[-1]; end
end
class StackTest < Minitest::Test

  SETS = [
    [],
    [0, 0, 0],
    [1, 0, 0],
    [0, 0, 1],
    [0, 1, 0],
    [0, 5, 5, 4],
    [5, 20, 3, 2, 1, 1, 1, -5]
  ]

  SETS.each do |set|
    (0...set.size).each do |push_index|
      current_set = set[0..push_index]
      define_method("test_#{current_set}_min_push_to_#{push_index}") do
        s = MinStack.new
        current_set.each { |value| s.push(value) }
        assert_equal(s.min, current_set.min)
      end

      (0...push_index).each do |pop_index|
        define_method("test_#{current_set}_min_pop_to_#{pop_index}") do
          s = MinStack.new
          current_set.each { |value| s.push(value) }
          pop_index.times { s.pop }
          assert_equal(s.min, set[0..(push_index-pop_index)].min)
        end
      end
    end
  end
end
