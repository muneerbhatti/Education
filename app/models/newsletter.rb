class Newsletter < ApplicationRecord
  enum :status, [ :subscribed, :unsubscribed ]

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true

  before_validation :set_default_status, on: :create

  private

  def set_default_status
    self.status ||= :subscribed
  end
end
