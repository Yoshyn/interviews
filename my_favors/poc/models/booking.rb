# frozen_string_literal: true

class Booking < ActiveRecord::Base

  has_many :prestationables, as: :relatable
  has_many :prestations, through: :prestationables
  has_many :appointments

  attribute :email, :string
  attribute :name, :string
  attribute :address, :string
  attribute :starts_at, :datetime
  attribute :lat, :float
  attribute :lng, :float
end
