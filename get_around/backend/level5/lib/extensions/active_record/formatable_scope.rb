# frozen_string_literal: true

require "active_record"
require 'active_support/concern'
require 'active_support/all'

module ActiveRecord::FormatableScope
  extend ActiveSupport::Concern
  class_methods do
    def formatable_scope(options = {})
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
      end

      define_singleton_method(:scoping_to_json) do |opts = {}|
        root, list = opts.delete(:root), scoping_as_json(opts)
        root_value = (root.is_a?(TrueClass) && table_name) || root.presence
        (root ? { root_value => list } : list).to_json
      end

      define_singleton_method(:scoping_to_xml) do |opts = {}|
        root, list = opts.delete(:root), scoping_as_json(opts)
        root_value = (root.is_a?(TrueClass) && table_name) || root.presence
        list.to_xml(root: root_value)
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::FormatableScope)
