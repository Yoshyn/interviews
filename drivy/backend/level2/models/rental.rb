# frozen_string_literal: true
require "active_record"
require_relative "../services/discouts/per_day"
require_relative '../lib/extensions/active_record/jsonable_scope'

class Rental < ActiveRecord::Base

  jsonable_scope(only: :id, methods: :price)

  belongs_to :car
  attribute :start_date, :date
  attribute :end_date, :date
  attribute :distance, :integer

  def price
    (Discounts::PerDay.combine(day_count) * car.price_per_day + distance * car.price_per_km).to_i
  end

  def day_count
  	(end_date - start_date).to_i + 1
  end
end
