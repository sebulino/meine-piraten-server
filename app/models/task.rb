class Task < ApplicationRecord
  belongs_to :category
  belongs_to :entity
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 2000 }
  validates :status, inclusion: { in: %w[open claimed completed done] }
  validate :valid_status_transition, if: :status_changed?

  private

  def valid_status_transition
    return if new_record?

    allowed = {
      "open" => %w[claimed],
      "claimed" => %w[completed open],
      "completed" => %w[done claimed],
      "done" => %w[]
    }

    unless allowed.fetch(status_was, []).include?(status)
      errors.add(:status, "cannot transition from '#{status_was}' to '#{status}'")
    end
  end
end
