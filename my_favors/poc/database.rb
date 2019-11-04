# frozen_string_literal: true
require "active_record"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :prestations, force: true do |t|
    t.string :reference, null: false
    t.integer :duration, null: false
  end

  create_table :prestationables, force: true do |t|
    t.references :prestation, null: false
    t.references :relatable, polymorphic: true, null: false
  end

  create_table :pros, force: true do |t|
    t.string :name, null: false
    t.string :address
    t.float :lat, null: false
    t.float :lng, null: false
    t.integer :max_kilometers, null: false, default: 10
  end

  create_table :opening_hours, force: true do |t|
    t.references :pro, null: false
    t.integer :day, null: false
    t.integer :starts_at, null: false
    t.integer :ends_at, null: false
  end

  create_table :bookings, force: true do |t|
    t.string :email, null: false
    t.string :name
    t.string :address
    t.datetime :starts_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    t.float :lat, null: false
    t.float :lng, null: false
  end

  create_table :appointments, force: true do |t|
    t.references :pro, null: false
    t.references :booking
    t.datetime :starts_at, null: false
    t.datetime :ends_at, null: false
  end
end

module GeoForSQLite
  RAD_PER_DEG = Math::PI / 180
  RM = 6371 # Earth radius in kmeters

  def self.crow_flies_km(lat1, lon1, lat2, lon2)
    lat1_rad, lat2_rad = lat1 * RAD_PER_DEG, lat2 * RAD_PER_DEG
    lon1_rad, lon2_rad = lon1 * RAD_PER_DEG, lon2 * RAD_PER_DEG

    a = Math.sin((lat2_rad - lat1_rad) / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin((lon2_rad - lon1_rad) / 2) ** 2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))

    RM * c # Delta in meters
  end

  def self.load!(sqlite_database)
    %w(cos acos sin).each do |math_method|
      sqlite_database.create_function math_method, 1 do |func, *args|
        func.result = Math.__send__(math_method, *args)
      end
    end
    sqlite_database.create_function 'crow_flies_km', 4 do |func, *args|
      func.result = crow_flies_km(*args)
    end
  end
end

GeoForSQLite.load!(ActiveRecord::Base.connection.raw_connection)

Dir["models/*.rb"].each { |model| require_relative model }
