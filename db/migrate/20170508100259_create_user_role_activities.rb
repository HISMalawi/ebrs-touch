class CreateUserRoleActivities < ActiveRecord::Migration
  def change
    create_table :user_role_activities do |t|
      t.integer :role_id
      t.integer :activity_id

      t.timestamps null: false
    end
  end
end
