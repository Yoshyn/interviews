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

  def drivy_fee
    ( commission - insurance_fee - assistance_fee ).to_i
  end

  def to_json
    { 
      insurance_fee: insurance_fee,
      assistance_fee: assistance_fee,
      drivy_fee: drivy_fee
    }
  end

  protected
  def commission
    @amount * TOTAL_PERCENT
  end  
end