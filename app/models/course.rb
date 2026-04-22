class Course < ApplicationRecord
  belongs_to :service
  belongs_to :instructor

  has_one_attached :image
end
