# frozen_string_literal: true

require 'bundler/setup'

require_relative 'database'
require_relative 'seeds'
require "minitest/autorun"

class RentalPriceTest < Minitest::Test

  EXPECTED_RAW = File.read('data/expected_output.json').gsub(/[[:space:]]/, '')
  EXPECTED_JSON = JSON.parse(EXPECTED_RAW)

  EXPECTED_JSON["rentals"].each do |attributes|
    id, price = attributes.slice("id", "price").values
    define_method("test_rental_price_#{id}") do
      assert_equal price, Rental.find(id).price
    end
  end

  def test_expected_output
    assert_equal EXPECTED_RAW, Rental.scoping_to_json
  end
end
