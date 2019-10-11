require "active_record"
require 'active_support/concern'

module ActiveRecord::JsonableScope
  extend ActiveSupport::Concern
  class_methods do
    def jsonable_scope(options = {})
      define_singleton_method(:scoping_as_json) do |opts = {}|
        records = (current_scope || all).map do |record|
          as_json_parameters = options.merge(opts)
          aliases            = as_json_parameters.delete(:aliases) || {}
          record_as_json     = record.as_json(as_json_parameters)
          aliases.each do |from, to|
            record_as_json[to] = record_as_json.delete(from)
          end
          record_as_json
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