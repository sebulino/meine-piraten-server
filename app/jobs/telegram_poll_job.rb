class TelegramPollJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 1.minute, attempts: 3

  def perform
    unless ENV.fetch("TELEGRAM_POLL_ENABLED", "true") == "true"
      Rails.logger.warn "TelegramPollJob: skipped because TELEGRAM_POLL_ENABLED is not 'true'"
      return
    end

    count = Telegram::ChannelPoller.new.poll_once
    Rails.logger.info "TelegramPollJob: poll returned #{count} posts"
  end
end
