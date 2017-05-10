class CreateTraditionalAuthorities < ActiveRecord::Migration
  def change
    create_table :traditional_authorities do |t|
      t.string :name
      t.integer :district_id

      t.timestamps null: false
    end
  end
end
