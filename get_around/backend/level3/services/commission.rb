class Commission

  TOTAL_PERCENT = 0.30

  def initialize(amount, day_count)
    @amount, @day_count = amount, day_count
  end


  def insurance_fee
    ( commission * 0.5 ).to_i
  end

  def assistance_fee
    @day_count * 100 # 1 euro in cents
  end

  def get_around_fee
    ( commission - insurance_fee - assistance_fee ).to_i
  end

  def to_json
    {
      insurance_fee: insurance_fee,
      assistance_fee: assistance_fee,
      get_around_fee: get_around_fee
    }
  end

  protected
  def commission
    @amount * TOTAL_PERCENT
  end
end