# frozen_string_literal: true
require "active_record"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :prestations, force: true do |t|
    t.string :reference
    t.integer :duration
  end

  create_table :prestationables, force: true do |t|
    t.references :prestation
    t.references :relatable, polymorphic: true
  end

  create_table :pros, force: true do |t|
    t.string :name
    t.string :address
    t.float :lat
    t.float :lng
    t.integer :max_kilometers
  end

  create_table :opening_hours, force: true do |t|
    t.references :pro
    t.integer :day
    t.integer :starts_at
    t.integer :ends_at
  end

  create_table :bookings, force: true do |t|
    t.string :email
    t.string :name
    t.string :address
    t.datetime :starts_at
    t.float :lat
    t.float :lng
  end

  create_table :appointments, force: true do |t|
    t.references :pro
    t.references :booking
    t.datetime :starts_at
    t.datetime :ends_at
  end
end

Dir["models/*.rb"].each { |model| require_relative model }
