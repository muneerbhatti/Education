class Instructor < ApplicationRecord
  belongs_to :course

  validates :name, :email, presence: true
  has_one_attached :image
end
