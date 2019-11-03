# frozen_string_literal: true


require_relative '../lib/active_record/type/hour_type'
# put this in config/initializers/types.rb
ActiveRecord::Type.register(:hours, HourType)

class OpeningHour < ActiveRecord::Base
  DAYS_MAPPING = {
    sunday: 1, monday: 2, tuesday: 4, wednesday: 8,
    thursday: 16, friday: 32, saturday: 64
  }
  enum day: DAYS_MAPPING

  scope :for_days, -> (*days) {
    where("day & ?", bitwise_for(days))
  }

  scope :match, -> (time, duration) { # Duration in second !
    dayname, start_hour = time.strftime("%A").downcase, HourType.new.cast(time)
    for_days(dayname).where("opening_hours.starts_at <= ? AND opening_hours.ends_at >= ?", start_hour, start_hour + duration)
  }

  attribute :starts_at, :hours
  attribute :ends_at, :hours

  private
  def self.bitwise_for(days)
    Array.wrap(days).sum { |day| DAYS_MAPPING[day.to_sym] }
  end
end
