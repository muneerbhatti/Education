class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.references :service, null: false, foreign_key: true
      t.string :title
      t.string :category
      t.string :difficulty
      t.integer :videos_count
      t.integer :duration_weeks
      t.integer :total_hours
      t.string :assignments
      t.decimal :price
      t.text :description

      t.timestamps
    end
  end
end
