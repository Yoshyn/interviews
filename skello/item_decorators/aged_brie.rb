require_relative './item_base'

module ItemDecorators
  class AgedBrie < ItemBase
    private
    def operator; '+'.to_sym end
  end
end
