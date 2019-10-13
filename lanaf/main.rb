begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  gem 'minitest'
end

require "minitest/autorun"

class Discount
  # Discount that can be apply.  NumberOfDistinct => Discount
  DISCOUNT_ROWS = { 1 => 100, 2 => 95, 3 => 90, 4 => 80, 5 => 75 }
  PER_PRICE = 8 # Per item price

  # Generate uniq sets of integer where the sum give the parameter rest
  # generate_sets(0) == [[]]
  # generate_sets(1) == [[1]]
  # generate_sets(2) == [[1,1], [2]]
  # generate_sets(3) == [[1, 1, 1], [2, 1], [3]]
  def self.generate_sets(rest)
    return [[]] if rest <= 0

    max_loop = [rest, DISCOUNT_ROWS.keys.max].min # Do not exeed the maximun available discount

    result = (1..max_loop).inject([]) do |acc, i|
      acc + generate_sets(rest-i).map do |array|
        if array.first && array.first > i
          array.push(i)
        else
          array.unshift(i);
        end
      end
    end
    result.uniq
  end

  # Check if a set is valid for product´s group id
  # valid_set?([1,1,1], [3])                        == false
  # valid_set?([1,1,2], [3])                        == false
  # valid_set?([1,2,3], [1, 2, 3])                  == false
  # valid_set?([1, 1, 1, 1, 1, 2, 2],[2, 2, 2, 1])  == false
  # valid_set?([1,1,2], [2, 1])                     == true
  # valid_set?([1,2,3], [1, 1, 1])                  == true
  def self.valid_set?(indexes, set = [])
    if set.empty?
      return true
    else
      indexes, set = indexes.dup, set.dup
      return false if indexes.uniq.count < set.max || indexes.count < set.inject(:+)
      max = set.delete_at(set.index(set.max))

      indexes.uniq.take(max).each do |number|
        if (index = indexes.index(number))
          indexes.delete_at(index)
        else
          return false
        end
      end
      valid_set?(indexes,set)
    end
  end

  # Return the pricing of a set of product´s group id
  # pricing([])                 == 0.0
  # pricing([1])                == 8.0
  # pricing([1,1])              == 16
  # pricing([1,2])              == 15.2
  # pricing([1,2,3])            == 21.6
  # pricing([1,1,2,3])          == 29.6
  # pricing([1,1,1,1,1,2,2])    == 54.4
  # pricing([1,1,2,2,3,3,4,5])  == 51.2
  def self.for(indexes)
    sets = generate_sets(indexes.count).select { |set| valid_set?(indexes,set) }

    results = sets.map do |set|
      set.inject(0) { |acc, number| acc += number * PER_PRICE * DISCOUNT_ROWS[number] }
    end

    (results.min)/100.0
  end
end

class DiscountTest < Minitest::Test
  def test_basics
    assert_equal(0, Discount.for([]))
    assert_equal(8, Discount.for([0]))
    assert_equal(8, Discount.for([1]))
    assert_equal(8, Discount.for([2]))
    assert_equal(8, Discount.for([3]))
    assert_equal(8, Discount.for([4]))
    assert_equal(8 * 2, Discount.for([0, 0]))
    assert_equal(8 * 3, Discount.for([1, 1, 1]))
  end

  def test_simple_discounts
    assert_equal(8 * 2 * 0.95, Discount.for([0, 1]))
    assert_equal(8 * 3 * 0.9, Discount.for([0, 2, 4]))
    assert_equal(8 * 4 * 0.8, Discount.for([0, 1, 2, 4]))
    assert_equal(8 * 5 * 0.75, Discount.for([0, 1, 2, 3, 4]))
  end

  def test_combinated_discounts
    assert_equal(8 + (8 * 2 * 0.95), Discount.for([0, 0, 1]))
    assert_equal((8 * 2 * 0.95) * 2, Discount.for([0, 0, 1, 1]))
    assert_equal((8 * 4 * 0.8) + (8 * 2 * 0.95), Discount.for([0, 0, 1, 2, 2, 3]))
    assert_equal(8 + (8 * 5 * 0.75), Discount.for([0, 1, 1, 2, 3, 4]))
  end

  def test_edge_cases
    assert_equal(2 * (8 * 4 * 0.8), Discount.for([0, 0, 1, 1, 2, 2, 3, 4]))
    # With the current algorithm, this test is extremly slow :/
    assert_equal(3 * (8 * 5 * 0.75) + 2 * (8 * 4 * 0.8),
      Discount.for([0, 0, 0, 0, 0,
             1, 1, 1, 1, 1,
             2, 2, 2, 2,
             3, 3, 3, 3, 3,
             4, 4, 4, 4]))
  end
end
