class ActionMatrix

  def self.read(role, states = [])
		states = states.collect{|s| s.strip.upcase}
		role = role.strip.upcase

    csv = CSV.read("#{Rails.root}/app/assets/data/action_matrix.csv").entries
		roles = csv.first.collect{|c| c.strip.upcase rescue nil}
		role_index = roles.index(role)

		results = []
		csv.each_with_index do |row, i|
			next if i == 0 
			state = row[0]
			next if state.blank?
			break if state.strip.upcase == "END"

			if states.include?(state.strip.upcase) 
				row.each_with_index do |data, j|
					next if role_index != j || data.blank?
					results << data.split(",")
				end
			end
		end		
	
		results = results.flatten.collect{|i| i.to_i}.sort.collect{|i| self.decode(i)}		
		results
  end

	def self.decode(n)		

    csv = CSV.read("#{Rails.root}/app/assets/data/action_matrix.csv").entries
		csv.each_with_index do |row, i|
			next if i == 0 
			code = row[0]
			next if code.blank?
			break if code.strip.upcase == "END CODES"

			if n.to_s == code.to_s 
				return {
					"code" => n,
					"desc" => row[1],
					"button_name" => row[2],
					"ajax_route" => row[3],
					"route" => row[4],
          "popup" => row[5],
          "class" => row[6]
				}
			end
		end		
	end
end
