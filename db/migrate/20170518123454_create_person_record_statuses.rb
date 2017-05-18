class CreatePersonRecordStatuses < ActiveRecord::Migration
  def change
    create_table :person_record_statuses do |t|

      t.timestamps null: false
    end
  end
end
