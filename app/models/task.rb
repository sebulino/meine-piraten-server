class Task < ApplicationRecord
  belongs_to :category
  belongs_to :entity
  belongs_to :assignee, class_name: "User", optional: true
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 2000 }
  validates :status, inclusion: { in: %w[open claimed completed done] }
  validate :valid_status_transition, if: :status_changed?

  after_create  :notify_todo_subscribers
  after_update  :notify_todo_subscribers, if: :notify_worthy_change?

  private

  def notify_worthy_change?
    saved_change_to_status? || saved_change_to_assignee_id?
  end

  def notify_todo_subscribers
    PushNotificationJob.perform_later(
      category: "todos",
      user_id: assignee_id,
      extra: { deepLink: "todo", todoId: id }
    )
  end

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
