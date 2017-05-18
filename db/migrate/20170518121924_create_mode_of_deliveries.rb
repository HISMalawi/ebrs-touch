class CreateModeOfDeliveries < ActiveRecord::Migration
  def change
    create_table :mode_of_deliveries do |t|

      t.timestamps null: false
    end
  end
end
