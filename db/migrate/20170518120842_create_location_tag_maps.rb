class CreateLocationTagMaps < ActiveRecord::Migration
  def change
    create_table :location_tag_maps do |t|

      t.timestamps null: false
    end
  end
end
