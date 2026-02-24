class ChannelPost < ApplicationRecord
  validates :chat_id, presence: true
  validates :message_id, presence: true, uniqueness: { scope: :chat_id }
  validates :posted_at, presence: true
end
