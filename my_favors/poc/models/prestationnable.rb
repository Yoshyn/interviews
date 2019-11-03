# frozen_string_literal: true

class Prestationable < ActiveRecord::Base
  belongs_to :prestation
  belongs_to :relatable, polymorphic: true

  scope :pros, -> { where(relatable_type: 'Pro')}
  scope :bookings, -> { where(relatable_type: 'booking')}
end