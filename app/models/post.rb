class Post < ApplicationRecord
  enum :status, [:draft,:published, :featured]

  validates :title, presence: true
  validates :body,  presence: true
  validates :slug,  presence: true, uniqueness: true

  before_validation :generate_slug, on: :create

  scope :published, -> { where(status: :published).order(published_at: :desc) }
  has_one_attached :featured_image

  private

  def generate_slug
    self.slug = title.to_s.parameterize
  end
end
