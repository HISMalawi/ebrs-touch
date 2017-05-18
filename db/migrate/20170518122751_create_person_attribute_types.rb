class CreatePersonAttributeTypes < ActiveRecord::Migration
  def change
    create_table :person_attribute_types do |t|

      t.timestamps null: false
    end
  end
end
