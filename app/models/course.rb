class Course < ApplicationRecord
  belongs_to :service

  has_one :instructor, dependent: :destroy
  accepts_nested_attributes_for :instructor, allow_destroy: true
  has_one_attached :image
end
