file_name = "chakhumbira.csv"
records = MassPerson.where("ta_created_at = 'Chakhumbira'")
header  = false

records.each do |record|

  pbd = PersonBirthDetail.where(" source_id LIKE '-%#{record.id}#%' ").first

  if header == false
    columns = record.as_json.keys
    columns << "BEN"
    columns << "eBRS Load Status"
    columns << "Record Status"
    columns << "eBRS Primary Key"

    File.open("#{file_name}", "w"){|f|
      f.write((columns.join("|") + "\n"))
    }
    header = true
  end

  load_check = RecordChecks.where(person_id: pbd.person_id).first.outcome
  record_status = PersonRecordStatus.status(pbd.person_id)

  values = record.as_json.values
  values << pbd.ben
  values << load_check
  values << record_status
  values << pbd.person_id

  File.open("#{file_name}", "a"){|f|
    f.write((values.join("|") + "\n"))
  }

  puts pbd.person_id
end