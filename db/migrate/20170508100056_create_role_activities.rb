class CreateRoleActivities < ActiveRecord::Migration
  def change
    create_table :role_activities do |t|
      t.string :activity

      t.timestamps null: false
    end
  end
end
