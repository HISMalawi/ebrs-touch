class CreateLevelOfEducations < ActiveRecord::Migration
  def change
    create_table :level_of_educations do |t|

      t.timestamps null: false
    end
  end
end
