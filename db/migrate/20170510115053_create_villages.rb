class CreateVillages < ActiveRecord::Migration
  def change
    create_table :villages do |t|
      t.string :name
      t.integer :traditional_authority_id

      t.timestamps null: false
    end
  end
end
