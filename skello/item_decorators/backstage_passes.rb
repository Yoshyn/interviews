require_relative './item_base'

module ItemDecorators
  class BackstagePasses < ItemBase

    def new_quality
      return 0 if @item.sell_in <= 0
      super()
    end

    def inc_or_dec_by;
      return 3 if @item.sell_in <= 5
      return 2 if @item.sell_in <= 10
      return 1
    end
    def operator; :+; end
  end
end
