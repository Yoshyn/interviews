# frozen_string_literal: true

require 'bundler/setup'

require_relative 'database'
require_relative 'seeds'
require "pry-byebug"

ActiveRecord::Base.logger.level = Logger::INFO

booking = Booking.create!(
  email: "sylvestre@fake.com",
  name: "Sylvestre",
  starts_at: "2019-08-27T14:00:00+02:00",
  lat: 48.922699,
  lng: 2.295130)
booking.prestations = Prestation.where(reference: "man_haircut")


puts "----------------------------------------------"
puts "Here is the available pros for your booking : "
puts booking.available_pros.pluck(:id, :name).to_s
puts "----------------------------------------------"

if pro_id = booking.available_pros.first.id
  booking.create_appointement_with(pro_id)
  puts "Yeh !, we just book the pro##{pro_id}"
end

puts "----------------------------------------------"
puts "Now, on reload the available pros for the same booking (even if it's not bookable anymore) : "
puts booking.available_pros.pluck(:id, :name).to_s
puts "It should have no more the pro##{pro_id}"
puts "----------------------------------------------"

binding.pry # Let's play

return
