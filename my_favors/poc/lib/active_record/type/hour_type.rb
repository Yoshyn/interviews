# frozen_string_literal: true

class HourType < ActiveRecord::Type::Integer

  SECOND_IN_DAY = (60 * 60 * 24)

  def cast(value)
    if value.kind_of?(String)
      super(Time.parse(value).to_i % SECOND_IN_DAY)
    elsif value.kind_of?(Time)
      super(value.to_i % SECOND_IN_DAY)
    else
      super
    end
  end

  def deserialize(value)
    value && Time.at(value).strftime("%H:%M") || cast(value)
  end
end
