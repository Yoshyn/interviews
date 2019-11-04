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
    assert_equal ["Nathalie", "Sophie"], Pro.open(Time.parse("2019-08-29 10:00:00"), 15 * 60).pluck(:name).sort
  end

  def test_pros_for_prestations_scope
    assert_equal ["Franck", "Sophie"], Pro.for_prestations("man_haircut").pluck(:name).sort
    assert_equal ["Franck", "Nathalie", "Sophie"], Pro.for_prestations("woman_shampoo").pluck(:name).sort
    assert_equal ["Sophie"], Pro.for_prestations("woman_color").pluck(:name).sort
    assert_equal ["Franck", "Sophie"], Pro.for_prestations("man_haircut", "woman_shampoo").pluck(:name).sort
    assert_equal ["Nathalie"], Pro.for_prestations("woman_shampoo", "woman_haircut", "woman_brushing").pluck(:name).sort
  end

  def test_pros_for_prestation_ids_scope
    prestation = Prestation.where(reference: "man_haircut").first!
    assert_equal ["Franck", "Sophie"], Pro.for_prestation_ids(prestation.id).pluck(:name).sort
    assert_equal ["Franck", "Sophie"], Pro.for_prestation_ids(prestation.id).pluck(:name).sort
    prestation = Prestation.where(reference: "woman_shampoo").first!
    assert_equal ["Franck", "Nathalie", "Sophie"], Pro.for_prestation_ids(prestation.id).pluck(:name).sort
    prestation = Prestation.where(reference: "woman_color").first!
    assert_equal ["Sophie"], Pro.for_prestation_ids(prestation.id).pluck(:name).sort
    prestation_ids = Prestation.where(reference: ["man_haircut", "woman_shampoo"]).pluck(:id)
    assert_equal ["Franck", "Sophie"], Pro.for_prestation_ids(*prestation_ids).pluck(:name).sort
    prestation_ids = Prestation.where(reference: ["woman_shampoo", "woman_haircut", "woman_brushing"]).pluck(:id)
    assert_equal ["Nathalie"], Pro.for_prestation_ids(*prestation_ids).pluck(:name).sort
  end

  def test_pros_booked_scope
    assert_equal ["Nathalie"], Pro.booked(Time.parse("2019-08-27 09:10:00")).pluck(:name).sort
    assert_equal ["Franck", "Sophie"], Pro.booked(Time.parse("2019-08-28T14:10:00")).pluck(:name).sort
  end

  def test_pros_available_at_scope
    assert_equal ["Nathalie"], Pro.available_at(Time.parse("2019-08-29 08:01:00"), 15 * 60).pluck(:name).sort
    assert_equal ["Franck", "Sophie"], Pro.available_at(Time.parse("2019-08-30 16:00:00"), 15 * 60).pluck(:name).sort
    assert_equal ["Franck", "Nathalie", "Sophie"], Pro.available_at(Time.parse("2019-08-30 16:40:00"), 15 * 60).pluck(:name).sort
  end

  def test_crow_flies_km_sql_result
    paris_lat, paris_lng = 48.8566, 2.3522
    rennes_lat, rennes_lng = 48.1135, -1.6757
    result = ActiveRecord::Base.connection.execute("SELECT CROW_FLIES_KM(#{paris_lat}, #{paris_lng}, #{rennes_lat}, #{rennes_lng}) AS CROW_FLIES_KM;")
    assert_equal(308, result[0]["CROW_FLIES_KM"].to_i)
  end

  def test_pros_not_too_far_from_scope
    lat, lng = 48.879240, 2.298816
    assert_equal ["Franck", "Nathalie", "Sophie"], Pro.not_too_far_from(lat, lng).pluck(:name).sort
    lat, lng = 48.922699, 2.295130
    assert_equal ["Franck", "Sophie"], Pro.not_too_far_from(lat, lng).pluck(:name).sort
    lat, lng = 48.825711, 2.273804
    assert_equal [], Pro.not_too_far_from(lat, lng).pluck(:name).sort
  end

  def test_booking_available_pros_method
    Booking.all.each do |booking| # Aucun ne match dans la base
      assert_equal 0, booking.available_pros.count
    end

    booking = Booking.create!(
      email: "_@test.com",
      starts_at: "2019-08-27T14:00:00+02:00",
      lat: 48.922699, lng: 2.295130)
    booking.prestations = Prestation.where(reference: "woman_haircut")
    assert_equal ["Franck", "Sophie"], booking.available_pros.pluck(:name).sort
    booking.prestations = Prestation.where(reference: ["woman_haircut", "woman_color"])
    assert_equal ["Sophie"], booking.available_pros.pluck(:name).sort
    booking.destroy
  end

  def test_fonctionnal # Same that in main.rb
    app_count = Appointment.count
    booking = Booking.create!(
      email: "sylvestre@fake.com",
      starts_at: "2019-08-27T14:00:00+02:00",
      lat: 48.922699, lng: 2.295130)
    booking.prestations = Prestation.where(reference: "man_haircut")
    assert_equal ["Franck", "Sophie"], booking.available_pros.pluck(:name).sort
    pro_id = booking.available_pros.first.id
    booking.create_appointement_with(pro_id)
    assert_equal app_count + 1, Appointment.count

    # Only one appointment per booking. For the moment.
    assert_raises("Booking::AppointmentAlreadyExist") { booking.create_appointement_with(1234567) }

    assert_equal ["Franck"], booking.available_pros.pluck(:name).sort
    booking.destroy
  end
end
