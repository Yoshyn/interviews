# frozen_string_literal: true

require_relative "commission"
require_relative "discouts/per_day"

module Actors
  class Actor

    delegate :distance, :day_count, :options, :price,  to: :@rental

    class_attribute :associated_options
    self.associated_options = []

    def initialize(rental)
      @rental = rental
      @commission = Commission.new(price, day_count)
    end

    def type;
      raise NotImplementedError.new("Actor should no be instanciate. You must inherit, then implement `#{__method__}. Should return either 'debit' or 'credit'")
    end

    def amount;
      raise NotImplementedError.new("Actor should no be instanciate. You must inherit, then implement `#{__method__}`.")
    end

    def options_price
      option_types = associated_options.presence && options.where(type: associated_options).pluck(:type)
      Option.price(option_types, day_count)
    end

    def as_json
      {
        "who" => self.class.name.demodulize.downcase,
        "type" => type,
        "amount" => amount
      }
    end
  end

  class Driver < Actor

    self.associated_options = [ :gps, :baby_seat, :additional_insurance ]

    def type; "debit"; end
    def amount; price + options_price; end
  end

  class Owner < Actor

    self.associated_options = [:baby_seat, :gps]

    def type; "credit"; end
    def amount; price - @commission.total_fee + options_price; end
  end

  class Insurance < Actor
    def type; "credit"; end
    def amount;@commission.insurance_fee; end
  end

  class Assistance < Actor
    def type; "credit"; end
    def amount; @commission.assistance_fee;end
  end

  class Drivy < Actor

    self.associated_options = :additional_insurance

    def type; "credit"; end
    def amount; @commission.drivy_fee + options_price; end
  end
end
