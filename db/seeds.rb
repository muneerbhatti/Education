# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


User.find_or_create_by!(email: 'aba@kaleidoscopekollege.com') do |user|
  user.first_name = 'Corie'
  user.last_name = ' '
  user.password = '123456'
end

WebsiteDetail.find_or_create_by!(email: 'aba@kaleidoscopekollege.com') do |company|
  company.name = 'Kaleidoscope Kollege'
  company.phone_1 = '(443) 822-4357'
  company.phone_2 = '(703) 718-6085'
  company.address_1 = 'your address'
  company.instagram = 'https://www.instagram.com/kaleidoscopekollege'
  company.facebook = 'https://www.facebook.com/Kaleidoscopekollege'
  company.about = 'Providing comprehensive ABA therapy and specialized support services to help individuals reach their full potential in life, learning, and community through evidence-based behavioral strategies combined with compassionate care.'
end
