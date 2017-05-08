class CreatePersonRecordStatuses < ActiveRecord::Migration
  def change
    create_table :person_record_statuses do |t|
      t.integer :person_id
      t.string :person_record_status_name

      t.timestamps null: false
    end
  end
end
