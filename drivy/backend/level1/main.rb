# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  git_source(:github) { |repo| "https://github.com/#{repo}.git" }
  gem "rails", github: "rails/rails"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :cars, force: true do |t|
    t.integer :price_per_day
    t.integer :price_per_km
  end

  create_table :rentals, force: true do |t|
    t.integer :car_id
    t.date :start_date
    t.date :end_date
    t.integer :distance
  end
end

class Car < ActiveRecord::Base
  has_many :rentals
  attribute :price_per_day, :integer
  attribute :price_per_km, :integer
end

class Rental < ActiveRecord::Base
  belongs_to :car
  attribute :start_date, :date
  attribute :end_date, :date
  attribute :distance, :integer

  def price
    number_of_days * car.price_per_day + distance * car.price_per_km 
  end

  def number_of_days
    (end_date - start_date).to_i + 1
  end

  def self.scoping_as_json(options = {}) 
    records = (current_scope || all).map do |record|
      record.as_json(options.presence || { only: :id, methods: :price })
    end
    { 'rentals' => records }
  end
end

class RentalPriceTest < Minitest::Test

  ## Before all for the poor.
  def self.run(*args)
    seed_file = File.read(File.join( __dir__, 'data/input.json'))
    seeds = JSON.parse(seed_file)
    seeds["cars"].each { |car| Car.create(car) }
    seeds["rentals"].each { |rental| Rental.create(rental) }
    super(*args)
    ActiveRecord::Base.subclasses.select(&:table_exists?).each(&:delete_all)
  end

  def test_seeds
    assert_equal 3, Car.count
    assert_equal 3, Rental.count
  end

  def test_rental_price_1
    assert_equal 7000, Rental.find(1).price
  end

  def test_rental_price_2
    assert_equal 15500, Rental.find(2).price
  end

  def test_rental_price_3
    assert_equal 11250, Rental.find(3).price
  end

  def test_expected_output
    expected_output = File.read(File.join( __dir__, 'data/expected_output.json'))
    assert_equal JSON.parse(expected_output), Rental.scoping_as_json
  end
end