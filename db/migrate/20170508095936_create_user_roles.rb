class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.string :level

      t.timestamps null: false
    end
  end
end
