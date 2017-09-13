class AuditTrail < ActiveRecord::Base
	self.table_name = :audit_trails
    self.primary_key = :audit_trail_id
    belongs_to :audit_trail_types , foreign_key: "audit_trail_type_id"
    include EbrsMetadata
end
