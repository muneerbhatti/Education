class CreateWebsiteDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :website_details do |t|
      t.string :name
      t.string :email
      t.string :address_1
      t.string :address_2
      t.string :phone_1
      t.string :phone_2
      t.string :instagram
      t.string :facebook
      t.string :twitter
      t.string :linkedin
      t.string :youtube
      t.string :social_media_1
      t.string :social_media_2
      t.text :about

      t.timestamps
    end
  end
end
