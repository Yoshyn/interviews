# frozen_string_literal: true

class Prestationable < ActiveRecord::Base
  belongs_to :prestation
  belongs_to :relatable, polymorphic: true
end