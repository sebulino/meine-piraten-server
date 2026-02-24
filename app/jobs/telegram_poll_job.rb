class TelegramPollJob < ApplicationJob
  queue_as :default

  def perform
    return unless ENV.fetch("TELEGRAM_POLL_ENABLED", "true") == "true"

    Telegram::ChannelPoller.new.poll_once
  end
end
