# frozen_string_literal: true
require "active_record"

require_relative '../lib/extensions/active_record/jsonable_scope'
require_relative "../services/actors"

class Rental < ActiveRecord::Base

  jsonable_scope(only: :id, methods: [:actions, :option_types] )

  belongs_to :car
  has_many :options
  attribute :start_date, :date
  attribute :end_date, :date
  attribute :distance, :integer

  def price
    (Discounts::PerDay.combine(day_count) * car.price_per_day + distance * car.price_per_km).to_i
  end

  def option_types; options.pluck(:type); end

  def actions
    %w(driver owner insurance assistance drivy).map do |actor|
      "Actors::#{actor.classify}".constantize.new(self).as_json
    end
  end

  def day_count
  	(end_date - start_date).to_i + 1
  end
end
