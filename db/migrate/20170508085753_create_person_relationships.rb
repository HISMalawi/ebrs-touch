class CreatePersonRelationships < ActiveRecord::Migration
  def change
    create_table :person_relationships do |t|
      t.integer :primary_person_id
      t.integer :secondary_person_id
      t.string :person_relationship

      t.timestamps null: false
    end
  end
end
