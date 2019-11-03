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

  def test_opening_hours_for_days_scope
    assert_equal 2, OpeningHour.for_days("monday").count
    assert_equal 2, OpeningHour.for_days("tuesday").count
    assert_equal 2, OpeningHour.for_days("wednesday").count
    assert_equal 3, OpeningHour.for_days("thursday").count
    assert_equal 3, OpeningHour.for_days("friday").count
    assert_equal 1, OpeningHour.for_days("saturday").count
    assert_equal 0, OpeningHour.for_days("sunday").count
    assert_equal 4, OpeningHour.for_days("monday", "tuesday").count
    assert_equal 7, OpeningHour.for_days("monday", "tuesday", "friday").count
  end

  def test_opening_hours_match_scope
    assert_equal 1, OpeningHour.match(Time.parse("1970-01-05 08:00:00"), 15 * 60).count
    assert_equal 2, OpeningHour.match(Time.parse("1970-01-05 09:00:00"), 15 * 60).count
    assert_equal 1, OpeningHour.match(Time.parse("1970-01-05 16:50:00"), 15 * 60).count
  end

  def test_pros_open_scope
    assert_equal ["Nathalie"], Pro.open(Time.parse("1970-01-05 08:00:00"), 15 * 60).pluck(:name).sort
    assert_equal ["Nathalie", "Sophie"], Pro.open(Time.parse("1970-01-05 09:00:00"), 15 * 60).pluck(:name).sort
  end
end