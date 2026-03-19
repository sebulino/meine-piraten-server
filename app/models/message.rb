class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  validates :body, presence: true

  after_create :notify_recipient

  private

  def notify_recipient
    PushNotificationJob.perform_later(
      category: "messages",
      user_id: recipient_id,
      extra: { deepLink: "message", topicId: id }
    )
  end
end
