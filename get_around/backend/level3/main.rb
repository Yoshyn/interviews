# frozen_string_literal: true

require 'bundler/setup'

require_relative 'database'
require_relative 'seeds'

File.open("data/output.json","w") do |f|
  f.write(Rental.scoping_to_json)
end
