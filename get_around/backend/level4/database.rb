# frozen_string_literal: true
require "active_record"
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

Dir["models/*.rb"].each { |model| require_relative model }
