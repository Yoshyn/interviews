# frozen_string_literal: true

require 'bundler/setup'

require_relative 'database'
require_relative 'seeds'

if ENV["PRODUCTION"].present?
  File.open("data/output.json","w") do |f|
    f.write(Rental.scoping_as_json)
  end
else
  require "minitest/autorun"

  class RentalPriceTest < Minitest::Test
    
    EXPECTED_JSON = JSON.parse(File.read('data/expected_output.json'))
    
    EXPECTED_JSON["rentals"].each do |attributes|
      id, price = attributes.slice("id", "price").values
      define_method("test_rental_price_#{id}") do 
        assert_equal price, Rental.find(id).price
      end
    end

    def test_expected_output
      assert_equal EXPECTED_JSON, Rental.scoping_as_json
    end
  end
end