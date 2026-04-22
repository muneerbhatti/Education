class CreateInstructors < ActiveRecord::Migration[8.0]
  def change
    create_table :instructors do |t|
      t.string :name
      t.string :email
      t.string :designation
      t.text :profile_description
      t.decimal :rating
      t.string :specialist

      t.timestamps
    end
  end
end
