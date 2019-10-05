# frozen_string_literal: true

module Actors
  class Actor
    def initialize(rental)
      @rental = rental
    end

    def type;
      raise NotImplementedError.new("Actor should no be instanciate. You must inherit, then implement `#{__method__}. Should return either 'debit' or 'credit'")
    end
    def amount;
      raise NotImplementedError.new("Actor should no be instanciate. You must inherit, then implement `#{__method__}`.")
    end

    def as_json
      {
        "who" => self.class.name.demodulize.underscore,
        "type" => type,
        "amount" => amount
      }
    end
  end

  class Driver < Actor
    def type; "debit"; end
    def amount; @rental.price end
  end

  class Owner < Actor
    def type; "credit"; end
    def amount; @rental.price - @rental.commission.values.sum end
  end

  class Insurance < Actor
    def type; "credit"; end
    def amount; @rental.commission["insurance_fee"]; end
  end

  class Assistance < Actor
    def type; "credit"; end
    def amount; @rental.commission["assistance_fee"]; end
  end

  class GetAround < Actor
    def type; "credit"; end
    def amount; @rental.commission["get_around_fee"]; end
  end
end
