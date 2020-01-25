require_relative './item_base'
require_relative './aged_brie'
require_relative './backstage_passes'
require_relative './sulfuras'
require_relative './conjured'

module ItemDecorators
  module Refine
    refine String do
      def classify
        split(/_|\s+/).collect!{ |w| w.capitalize }.join
      end
    end
  end

  class Factory
    using Refine
    REGEXP = /(?:aged\sbrie|backstage\spasses|sulfuras|conjured)\.*/i

    def self.make(item)
      if match_data = REGEXP.match(item.name)
        klass(match_data[0]).new(item)
      else
        ItemDecorators::ItemBase.new(item)
      end
    end

    private
    def self.klass(klass_name)
      const_name = "ItemDecorators::#{klass_name.classify}"
      Object.const_get(const_name) # rescue ItemDecorators::ItemBase.new(item) ?
    end
  end
end
