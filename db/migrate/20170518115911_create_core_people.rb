class CreateCorePeople < ActiveRecord::Migration
  def change
    create_table :core_people do |t|

      t.timestamps null: false
    end
  end
end
