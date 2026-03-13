class Service < ApplicationRecord
  has_many :courses, dependent: :destroy
  accepts_nested_attributes_for :courses, allow_destroy: true
  has_one_attached :image

  def total_instructors
    1
    # courses.pluck(:instructor_id).uniq.count
  end
end
