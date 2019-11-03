# frozen_string_literal: true

class Appointment < ActiveRecord::Base
  belongs_to :pro
  belongs_to :booking

  attribute :starts_at, :datetime
  attribute :ends_at, :datetime
end
