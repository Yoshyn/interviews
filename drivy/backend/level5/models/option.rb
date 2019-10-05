# frozen_string_literal: true
require "active_record"

class Option < ActiveRecord::Base
  belongs_to :rental

  self.inheritance_column = nil # Otherwise type is reserved for STI...

  enum type: { gps: 0, baby_seat: 1, additional_insurance: 2 }

  PRICE_PER_DAY = {
    "gps" => 500, # 5 euro
    "baby_seat" => 200, # 2 euro
    "additional_insurance" => 1000, # 10 euro
  }

  def self.price(types, day_count)
    Array.wrap(types).map { |type|
      PRICE_PER_DAY[type] * day_count
    }.sum
  end
end