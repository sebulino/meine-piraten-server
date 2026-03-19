class ChannelPost < ApplicationRecord
  scope :recent, -> { where(posted_at: 30.days.ago..) }

  validates :chat_id, presence: true
  validates :message_id, presence: true, uniqueness: { scope: :chat_id }
  validates :posted_at, presence: true

  after_create :notify_news_subscribers

  private

  def notify_news_subscribers
    PushNotificationJob.perform_later(
      category: "news",
      extra: { deepLink: "forum" }
    )
  end
end
