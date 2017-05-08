class CreatePersonAttributes < ActiveRecord::Migration
  def change
    create_table :person_attributes do |t|
      t.integer :person_id
      t.string :person_attribute_value
      t.integer :person_attribute_type_id

      t.timestamps null: false
    end
  end
end
