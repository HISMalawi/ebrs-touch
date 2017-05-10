class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name
      t.string :nationality
      t.string :continent
      t.integer :country_code
      t.string :country_short_code  
      t.string :region
      t.string :sub_region
      t.string :world_region
      t.string :currency
      t.string :ioc
      t.string :gec

      t.timestamps null: false
    end
  end
end
