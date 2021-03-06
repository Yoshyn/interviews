require "active_record"
require 'active_support/concern'

module ActiveRecord::JsonableScope
  extend ActiveSupport::Concern
  class_methods do
    def jsonable_scope(options = {})
      define_singleton_method(:scoping_as_json) do |opts = {}|
        records = (current_scope || all).map do |record|
          record.as_json(opts.presence || options)
        end
        { table_name => records }
      end

      define_singleton_method(:scoping_to_json) do |opts = {}|
        scoping_as_json(opts).to_json
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::JsonableScope)