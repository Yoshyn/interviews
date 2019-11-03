# frozen_string_literal: true

require 'bundler/setup'

require_relative 'database'
require_relative 'seeds'
require "minitest/autorun"

require "pry-byebug"


class SeedsTest < Minitest::Test


  EXPECTED_DATA = JSON.parse(File.read('data/input.json'))
  ASSOC_METHODS = %w(prestations opening_hours appointments)

  SEARCH_KEYS = {
    "bookings" => %w(email starts_at ends_at lat lng),
    "pros" => %w(name address lat lng max_kilometers)
  }

  EXPECTED_DATA.each do |table, records|
    klass = table.classify.constantize

    define_method("test_#{table}_count") do
      assert_equal records.count, klass.count
    end

    records.each do |record|
      record.slice(*ASSOC_METHODS).each do |assoc, list|
        define_method("test_#{klass}_#{assoc}_count") do
          instance = klass.where(record.slice(*SEARCH_KEYS[table])).first!
          assert_equal list.count, instance.__send__(assoc).count
        end
      end
    end
  end

  def test_prestations_assoc_count
    EXPECTED_DATA.slice("bookings", "pros").each do |assoc, records|
      expected = records.map { |attrs| attrs["prestations"] }.flatten.inject(Hash.new(0)) { |h, e|
        h[e] += 1 ; h
      }
      expected.each do |reference, count|
        assoc_count = Prestation.where(reference: reference).first!.__send__(assoc).count
        assert_equal count, assoc_count
      end
    end
  end
end
