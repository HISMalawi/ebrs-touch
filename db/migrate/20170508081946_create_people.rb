class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.integer :person_type_id, null: false
      t.string :first_name, null: false
      t.string :middle_name
      t.string :last_name, null: false
      t.string :gender, null: false
      t.datetime :birthdate, null: false
      t.integer :creator, null: false
      t.string :site_created, null: false 
      t.boolean :birthdate_estimated, null: false, default: 0

      t.timestamps null: false
    end
  end
end
