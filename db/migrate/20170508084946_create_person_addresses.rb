class CreatePersonAddresses < ActiveRecord::Migration
  def change
    create_table :person_addresses do |t|
      t.integer :person_id, null: false
      t.integer :current_village
      t.string :current_village_other
      t.integer :current_ta
      t.string :current_ta_other
      t.integer :current_district
      t.string :current_district_other
      t.integer :home_village
      t.string :home_village_other
      t.integer :home_ta
      t.string :home_ta_other
      t.integer :home_district
      t.string :home_district_other
      t.integer :citizenship, null: false
      t.integer :residential_country, null: false

      t.timestamps null: false
    end
  end
end
