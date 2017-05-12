class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :person_id
      t.string :username
      t.string :password_hash
      t.datetime :last_password_date
      t.integer :password_attempt
      t.integer :login_attempt
      t.string :email_address
      t.boolean :active
      t.boolean :notify
      t.integer :role
      t.integer :site_code
      t.string :plain_password
      t.string :reason
      t.string :signature

      t.timestamps null: false
    end
  end
end
