# frozen_string_literal: true

class Pro < ActiveRecord::Base

  has_many :prestationables, as: :relatable
  has_many :prestations, through: :prestationables
  has_many :opening_hours
  has_many :appointments

  scope :open, -> (time, duration) {
    joins(:opening_hours).merge(OpeningHour.match(time, duration))
  }

  attribute :name, :string
  attribute :address, :string
  attribute :lat, :float
  attribute :lng, :float
  attribute :max_kilometers, :integer
end
