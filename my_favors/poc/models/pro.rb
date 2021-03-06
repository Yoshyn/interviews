# frozen_string_literal: true

class Pro < ActiveRecord::Base

  has_many :prestationables, as: :relatable
  has_many :prestations, through: :prestationables
  has_many :opening_hours
  has_many :appointments

  # Not supported by sqlite but please consider a materialized view for this in other SGBD !
  scope :for_prestations, -> (*references) {
    if (list = Array.wrap(references)).many?
      sub_query_sql = Prestationable.pros.select("relatable_id")
        .joins(:prestation)
        .where(prestations: { reference: list})
        .group(:relatable_id).having("COUNT(distinct reference) = ?", list.count)
        .to_sql
      joins("INNER JOIN (#{sub_query_sql}) AS ipt ON ipt.relatable_id = pros.id").distinct
    else
      joins(:prestations).where(prestations: { reference: list})
    end
  }

  scope :for_prestation_ids, -> (*ids) {
    list = Array.wrap(ids).flatten
    if list.many?
      sub_query_sql = Prestationable.pros.select("relatable_id")
        .where(prestation_id: ids)
        .group(:relatable_id).having("COUNT(relatable_id) = ?", list.count)
        .to_sql
      joins("INNER JOIN (#{sub_query_sql}) AS ipt ON ipt.relatable_id = pros.id").distinct
    else
      joins(:prestations).where(prestations: { id: list})
    end
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
        #{Pro.unscoped.select(:id).open(time, duration).to_sql}
        EXCEPT
        #{Pro.unscoped.select(:id).booked(time).to_sql}
      ) AS ipt ON ipt.id = pros.id")
  }

  attribute :name, :string
  attribute :address, :string
  attribute :lat, :float
  attribute :lng, :float
  attribute :max_kilometers, :integer
end
