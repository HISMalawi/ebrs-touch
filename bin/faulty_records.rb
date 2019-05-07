file_name = "failed_records.json"
records = MassPerson.all
header  = false

records.each_with_index do |record|

  pbd = PersonBirthDetail.where(" source_id LIKE '-%#{record.id}#%' ").first

  if header == false
    columns = record.as_json.keys

    File.open("#{file_name}", "w"){|f|
      f.write((columns.join("|") + "\n"))
    }
    header = true
  end

	next if !pbd.blank?

  values = record.as_json.values

  File.open("#{file_name}", "a"){|f|
    f.write((values.join("|") + "\n"))
  }

end
