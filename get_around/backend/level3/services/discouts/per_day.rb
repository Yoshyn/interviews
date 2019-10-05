module Discounts
	class PerDay

		# Manage discount datas as array of attributes.
		# Maybe it will require a dedicated model one day if the product whant the ability 
		# to dynamically update or add discounts
		ROWS = [
			{ after: 10, decrease: 0.5 },
			{ after: 4,  decrease: 0.7 },
			{ after: 1,  decrease: 0.9 },
			{ after: 0,  decrease: 1 }
		]

		def initialize(day_index)
			@day_index = day_index
		end

		def discount
			ROWS.find { |row| @day_index >= row[:after] }[:decrease]
		end

		def self.combine(day_count)
			(0...day_count).map { |day_index| 
				Discounts::PerDay.new(day_index).discount
			}.sum
		end
	end
end