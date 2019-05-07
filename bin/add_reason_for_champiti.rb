file_name = "champiti_load.csv"
final_file_name = "champiti_load_extra_columns.csv"

header = false
ebrs_status_index = -1
ebrs_key_index    = -1

CSV.foreach(file_name) do |row|

  data = row.first.split("|")

  if header == false
    ebrs_status_index = data.index("eBRS Load Status")
    ebrs_key_index    = data.index("eBRS Primary Key")

    data << "Reason For Incompleteness"
    data << "Associated/Existing Duplicate Records"
    File.open(final_file_name, "w"){|f|
      line = data.join("|") + "\n"
      f.write(line)
    }
    header = true
    next
  end

  status    = data[ebrs_status_index]
  person_id = data[ebrs_key_index]
  pd_data = []
  incomplete_reason = ""
  puts person_id

  if status == "Incomplete Record"
    #Re-run completeness auto check
    detail    = PersonBirthDetail.where(person_id: person_id).first
    mass_person_id = detail.source_id.split("#").first.to_i * -1
    record = MassPerson.find(mass_person_id)

    missing_fields = []
    check_fields = ["last_name",
     "first_name",
     "gender",
     "date_of_birth",
     "mother_last_name",
     "mother_first_name",
     "mother_nationality",
     "district_of_birth",
     "ta_of_birth",
     "village_of_birth"
    ]

    if (!record["father_first_name"].blank? ||
        !record["father_last_name"].blank? ||
            !record["father_nationality"].blank? )
      check_fields = check_fields + [
          "father_first_name",
          "father_last_name",
          "father_nationality"
      ]
    end

    check_fields.each do |field|

      if record[field].blank?
        missing_fields << field.titleize
      end
    end

    incomplete_reason = "Missing Fields: " + missing_fields.join(" & ")
  end

  if status.to_s.match("Duplicate")
    pd          = PotentialDuplicate.where(person_id: person_id).first
    dup_records = DuplicateRecord.where(potential_duplicate_id: pd.id)

    dup_records.each do |exi_record|
      e_detail = PersonBirthDetail.where(person_id: exi_record.person_id).first
      ben      = e_detail.ben
      if !ben.blank?
        pd_data << ben
      else
        pd_data << "eBRS_Person_id=" + e_detail.person_id.to_s
      end
    end
  end

  data << incomplete_reason
  data << pd_data.join("#")

  File.open(final_file_name, "a"){|f|
    line = data.join("|") + "\n"
    f.write(line)
  }
end