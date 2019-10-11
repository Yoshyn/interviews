# frozen_string_literal: true

require 'bundler/setup'

require_relative 'database'
require_relative 'seeds'
require "minitest/autorun"

class RentalPriceTest < Minitest::Test

  EXPECTED_RAW = File.read('data/expected_output.json').gsub(/[[:space:]]/, '')
  EXPECTED_JSON = JSON.parse(EXPECTED_RAW)

  EXPECTED_JSON["rentals"].each do |attributes|
    id, options, actions = attributes.slice("id", "options", "actions").values

    define_method("test_rental_#{id}_options}") do
      assert_equal options, Rental.find(id).option_types
    end

    actions.each do |action_as_json|
      define_method("test_rental_#{id}_action_#{action_as_json['who']}") do
        assert_includes Rental.find(id).actions, action_as_json
      end
    end
  end

  def test_expected_output
    alpha_sort = -> (string) { string.chars.sort.join }
    assert_equal EXPECTED_JSON, Rental.scoping_as_json(aliases: { "option_types" => "options" })
    assert_equal(
      alpha_sort.call(EXPECTED_RAW),
      alpha_sort.call(
        Rental.scoping_to_json(aliases: { "option_types" => "options" })
      )
    )
  end
end
