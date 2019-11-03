# frozen_string_literal: true

class Pro < ActiveRecord::Base

  has_many :prestationables, as: :relatable
  has_many :prestations, through: :prestationables
  has_many :opening_hours
  has_many :appointments

  # Not supported by sqlite but please consider a materialized view for this in other SGBD !
  scope :for, -> (*references) {
    pro_query_ids = Array.wrap(references).map do |reference|
      Prestationable.pros.select("relatable_id")
        .joins(:prestation)
        .where(prestations: { reference: reference}).to_sql
    end
    current_scope.joins("INNER JOIN (#{pro_query_ids.join(" INTERSECT ")}) AS PF ON PF.relatable_id = pros.id")
  }

  scope :open, -> (time, duration) {
    joins(:opening_hours).merge(OpeningHour.match(time, duration))
  }

  attribute :name, :string
  attribute :address, :string
  attribute :lat, :float
  attribute :lng, :float
  attribute :max_kilometers, :integer
end
