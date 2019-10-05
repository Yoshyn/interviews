# frozen_string_literal: true

class Commission

  TOTAL_PERCENT = 0.30

  def initialize(amount, day_count)
    @amount, @day_count = amount, day_count
  end

  def insurance_fee
    ( total_fee * 0.5 ).to_i
  end

  def assistance_fee
    @day_count * 100 # 1 euro in cents
  end

  def drivy_fee
    ( total_fee - insurance_fee - assistance_fee ).to_i
  end

  def total_fee
    (@amount * TOTAL_PERCENT).to_i
  end
end