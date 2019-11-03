# frozen_string_literal: true

class HourType < ActiveRecord::Type::Integer

  def cast(value)
    if value.kind_of?(String)
      super(Time.parse(value).seconds_since_midnight())
    elsif value.kind_of?(Time)
      super(value.seconds_since_midnight())
    else
      super
    end
  end

  def deserialize(value)
    value && Time.at(value).utc.strftime("%H:%M") || cast(value)
  end
end
