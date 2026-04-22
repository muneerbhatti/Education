class Instructor < ApplicationRecord
  has_many :courses, dependent: :destroy
  accepts_nested_attributes_for :courses, allow_destroy: true

  validates :name, :email, presence: true
  has_one_attached :image
end
