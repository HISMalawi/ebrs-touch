class CreatePersonRelationTypes < ActiveRecord::Migration
  def change
    create_table :person_relation_types do |t|

      t.timestamps null: false
    end
  end
end
