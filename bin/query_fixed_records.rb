voided = PersonRecordStatus.where(" comments = 'Voided Due to Location Sync Anomaly' ").map(&:person_id).uniq
fixed  = PersonRecordStatus.where(" comments = 'Location ID Fix' ").map(&:person_id).uniq
person_ids = voided + fixed
person_ids = person_ids.join("\n")
File.open("pids", "w"){|f| f.write(person_ids)}
