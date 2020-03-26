#Usage rails runner bin/load_ta_from_mass_data_csv.rb path_to_csv_of_all_data.csv ta_name
require "csv"

file_name = ARGV[0]
target_ta_name   = ARGV[1]

if file_name.blank? || !File.exist?(file_name)
  raise "Missing file_name: #{file_name}"
end

if target_ta_name.blank?
  raise "Missing TA name: #{target_ta_name}"
end

ta_col_index      = nil
columns = MassPerson.new.attributes.keys
columns[0] = 'mass_person_id'

CSV.foreach(file_name, col_sep: "|").each {|data|

  if ta_col_index.blank?
    ta_col_index    = data.index("ta_created_at")
  else

    ta    = data[ta_col_index]
    next if ta.to_s.strip != target_ta_name.to_s.strip

    hash = {}
    data.each_with_index do |v, i|
      hash[columns[i]] = v
    end

    mass_person = MassPerson.new(hash)
    puts "#{mass_person.first_name} # #{mass_person.last_name}"
    mass_person.mass_person_id = (MassPerson.count > 0 ? (MassPerson.last.mass_person_id + 1) : 1)
    mass_person.save
  end
}
