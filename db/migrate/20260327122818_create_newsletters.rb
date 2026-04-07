class CreateNewsletters < ActiveRecord::Migration[8.0]
  def change
    create_table :newsletters do |t|
      t.string :email, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :newsletters, :email, unique: true
  end
end
