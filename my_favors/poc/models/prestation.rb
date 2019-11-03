# frozen_string_literal: true

class Prestation < ActiveRecord::Base
  attribute :reference, :string
  attribute :duration, :integer

  has_many :prestationables
  has_many :pros, through: :prestationables, source: :relatable, source_type: "Pro"
  has_many :bookings, through: :prestationables, source: :relatable, source_type: "Booking"
end