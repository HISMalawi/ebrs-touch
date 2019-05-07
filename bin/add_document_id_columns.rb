tables = ["UserRole",
          "PersonName",
          "PersonAttribute",
          "BarcodeIdentifier",
          "PersonAddress",
          "PersonBirthDetail",
          "PersonNameCode",
          "PersonIdentifier",
          "PersonRecordStatus",
          "AuditTrail",
          "CorePerson",
          "PersonRelationship",
          "Person",
          "User"]

tables.each do |table|

	table_name = eval(table).table_name
	puts "Adding document_id for table: '#{table_name}'"
	if !eval(table).new.attributes.has_key?("document_id")
		ActiveRecord::Base.connection.execute("ALTER TABLE #{table_name} ADD COLUMN document_id VARCHAR(255);")
	end
end
