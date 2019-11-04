# frozen_string_literal: true

class Pro < ActiveRecord::Base

  has_many :prestationables, as: :relatable
  has_many :prestations, through: :prestationables
  has_many :opening_hours
  has_many :appointments

  # Not supported by sqlite but please consider a materialized view for this in other SGBD !
  scope :for_prestations, -> (*references) {
    sub_queries_sql = Array.wrap(references).flatten.map do |reference|
      Prestationable.pros.select("relatable_id")
        .joins(:prestation)
        .where(prestations: { reference: reference}).to_sql
    end
    joins("INNER JOIN (#{sub_queries_sql.join(" INTERSECT ")}) AS ipt ON ipt.relatable_id = pros.id").distinct
  }

  scope :for_prestation_ids, -> (*ids) {
    sub_queries_sql = Array.wrap(ids).flatten.map do |id|
      Prestationable.pros.select("relatable_id").where(prestation_id: id).to_sql
    end
    joins("INNER JOIN (#{sub_queries_sql.join(" INTERSECT ")}) AS ipt ON ipt.relatable_id = pros.id").distinct
  }

  scope :not_too_far_from, -> (lat, lng) {
    where("CROW_FLIES_KM(pros.lat, pros.lng, ?, ? ) <= pros.max_kilometers", lat, lng)
  }

  scope :open, -> (time, duration) {
    joins(:opening_hours).merge(OpeningHour.match(time, duration))
  }

  scope :booked, -> (time) {
    joins(:appointments).where("? BETWEEN appointments.starts_at AND appointments.ends_at", time)
  }

  scope :available_at, -> (time, duration) {
    joins("
      INNER JOIN (
        #{self.select(:id).open(time, duration).to_sql}
        EXCEPT
        #{self.select(:id).booked(time).to_sql}
      ) AS ipt ON ipt.id = pros.id")
  }

  attribute :name, :string
  attribute :address, :string
  attribute :lat, :float
  attribute :lng, :float
  attribute :max_kilometers, :integer
end
