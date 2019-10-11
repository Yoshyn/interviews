# frozen_string_literal: true

require 'bundler/setup'

require_relative 'database'
require_relative 'seeds'
require "minitest/autorun"

class RentalPriceTest < Minitest::Test

  EXPECTED_RAW = File.read('data/expected_output.json').gsub(/[[:space:]]/, '')
  EXPECTED_JSON = JSON.parse(EXPECTED_RAW)

  EXPECTED_JSON["rentals"].each do |attributes|
    id, actions = attributes.slice("id", "actions").values
    actions.each do |action_as_json|
      define_method("test_rental_action_#{id}_#{action_as_json['who']}") do
        assert_includes Rental.find(id).actions, action_as_json
      end
    end
  end

  def test_actor_as_json
    assert_raises(NotImplementedError) { Actors::Actor.new(nil).as_json }
  end

  def test_expected_output
    assert_equal EXPECTED_RAW, Rental.scoping_to_json(only: :id, methods: :actions)
  end
end
