class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.integer :country_id 
      t.string :code
      t.string :name
      t.string :region

      t.timestamps null: false
    end
  end
end
