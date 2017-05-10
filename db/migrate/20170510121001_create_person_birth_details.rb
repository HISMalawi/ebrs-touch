class CreatePersonBirthDetails < ActiveRecord::Migration
  def change
    create_table :person_birth_details do |t|
      t.integer :person_id
      t.string :place_of_birth
      t.integer :hospital_of_birth
      t.string :birth_address
      t.integer :birth_village
      t.integer :birth_ta
      t.integer :birth_district
      t.string :other_birth_place_details
      t.decimal :birth_weight
      t.string :type_of_birth
      t.string :other_type_of_birth
      t.boolean :parents_married_to_each_other
      t.datetime :date_of_marriage
      t.integer :gestation_at_birth
      t.integer :number_of_prenatal_visits
      t.integer :month_prenatal_care_started
      t.string :mode_of_delivery
      t.integer :alive_inclusive
      t.integer :still_alive
      t.string :level_of_education
      t.integer :district_id_number
      t.integer :facility_code
      t.integer :district_code
      t.integer :national_serial_number
      t.boolean :court_order_attached
      t.boolean :parents_signed
      t.boolean :form_signed
      t.datetime :acknowledgement_date
      t.integer :facility_serial_number
      t.string :guardianship
      t.boolean :adoption_court_order

      t.timestamps null: false
    end
  end
end
