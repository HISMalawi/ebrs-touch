class CreatePersonAttributeTypes < ActiveRecord::Migration
  def change
    create_table :person_attribute_types do |t|
      t.string :person_attribute_name

      t.timestamps null: false
    end
  end
end
