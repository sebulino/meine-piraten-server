class AdminRequest < ApplicationRecord
  belongs_to :user
  belongs_to :reviewed_by, class_name: "User", optional: true

  validates :reason, presence: true
  validates :status, inclusion: { in: %w[pending approved rejected] }
  validate :only_one_pending_request_per_user, on: :create

  scope :pending, -> { where(status: "pending") }

  private

  def only_one_pending_request_per_user
    return unless status == "pending" && user && AdminRequest.pending.exists?(user: user)

    errors.add(:base, "Es liegt bereits eine offene Anfrage vor.")
  end
end
