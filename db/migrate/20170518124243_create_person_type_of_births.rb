class CreatePersonTypeOfBirths < ActiveRecord::Migration
  def change
    create_table :person_type_of_births do |t|

      t.timestamps null: false
    end
  end
end
