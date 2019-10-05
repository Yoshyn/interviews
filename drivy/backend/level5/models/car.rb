# frozen_string_literal: true
require "active_record"

class Car < ActiveRecord::Base
  has_many :rentals
  attribute :price_per_day, :integer
  attribute :price_per_km, :integer
end