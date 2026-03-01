class TelegramPollJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 1.minute, attempts: 3

  def perform
    return unless ENV.fetch("TELEGRAM_POLL_ENABLED", "true") == "true"

    count = Telegram::ChannelPoller.new.poll_once
    Rails.logger.info "TelegramPollJob: poll returned #{count} posts"
  end
end
