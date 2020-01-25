require_relative './item_base'

module ItemDecorators
  class Conjured < ItemBase
    private
    def inc_or_dec_by; super() * 2; end
  end
end
