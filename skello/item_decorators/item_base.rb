module ItemDecorators
  class ItemBase
    QUALITY_MIN, QUALITY_MAX = 0, 50

    def initialize(item); @item = item; end

    def update
      if quality > QUALITY_MIN &&
        quality <= QUALITY_MAX
        update_quality
      end
      @item.sell_in -= 1
    end

    private
    def quality; @item.quality; end

    def update_quality
      nq = new_quality
      nq = QUALITY_MAX if nq > QUALITY_MAX
      nq = QUALITY_MIM if nq < QUALITY_MIN
      @item.quality = nq
    end

    def new_quality
      quality.public_send(operator, inc_or_dec_by)
    end

    def inc_or_dec_by
      @item.sell_in < 1 ? 2 : 1
    end

    def operator; :-; end
  end
end
