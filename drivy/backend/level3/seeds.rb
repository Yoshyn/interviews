# frozen_string_literal: true

seed_file = File.read(File.join( __dir__, 'data/input.json'))
seeds = JSON.parse(seed_file)

seeds.each do |model_name, rows|
	rows.each do |row|
		model_name.classify.constantize.create!(row)
	end
end
