# frozen_string_literal: true

seed_file = File.read(File.join( __dir__, 'data/input.json'))
seeds = JSON.parse(seed_file)

seeds["prestations"].each do |attrs|
  Prestation.create!(
    reference: attrs["reference"], duration: attrs["duration"] * 60
  )
end

seeds["bookings"].each do |attrs|
  prestation_reference = attrs.delete("prestations")
  prestations = prestation_reference.map { |reference| Prestation.where(reference: reference).first! }
  record = Booking.create!(attrs)
  record.prestations = prestations
end

seeds["pros"].each do |attrs|
  prestation_reference = attrs.delete("prestations")
  prestations = prestation_reference.map { |reference| Prestation.where(reference: reference).first! }

  opening_hours, appointments = attrs.delete("opening_hours"), attrs.delete("appointments")

  record = Pro.create!(attrs)
  record.prestations = prestations
  opening_hours.each do  |oh_attrs|
    OpeningHour.create!(oh_attrs.merge(pro_id: record.id))
  end
  appointments.each do  |ap_attrs|
    Appointment.create!(ap_attrs.merge(pro_id: record.id))
  end
end
