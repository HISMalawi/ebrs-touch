class CreateHealthFacilities < ActiveRecord::Migration
  def change
    create_table :health_facilities do |t|
      t.integer :district_id
      t.string :code
      t.string :name
      t.string :zone
      t.string :fac_type
      t.string :mga
      t.string :latitude
      t.string :longitude

      t.timestamps null: false
    end
  end
end
