# frozen_string_literal: true

class Booking < ActiveRecord::Base

  has_many :prestationables, as: :relatable
  has_many :prestations, through: :prestationables
  has_one :appointment, dependent: :destroy

  # After
  # before_validation do
  #   lat, lng = Geocoder.search(address)
  # end

  def available_pros
    Pro.for_prestation_ids(prestation_ids)
      .not_too_far_from(lat, lng)
      .available_at(starts_at, total_durations)
  end

  def create_appointement_with(pro_id)
    raise "Booking::AppointmentAlreadyExist" if appointment
    # raise if not in the pro_id available ?
    create_appointment!(
      pro_id: pro_id,
      starts_at: starts_at,
      ends_at: starts_at + total_durations)
  end

  def total_durations
    prestations.sum(:duration)
  end

  attribute :email, :string
  attribute :name, :string
  attribute :address, :string
  attribute :starts_at, :datetime
  attribute :lat, :float
  attribute :lng, :float
end
