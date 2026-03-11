namespace :telegram do
  desc "Show Telegram bot status: webhook, cursor, channel_posts count, env vars"
  task status: :environment do
    token = ENV["TELEGRAM_BOT_TOKEN"]

    puts "=== Environment ==="
    puts "TELEGRAM_BOT_TOKEN: #{token.present? ? "set (#{token.first(6)}...)" : "MISSING"}"
    puts "TELEGRAM_CHAT_ID: #{ENV["TELEGRAM_CHAT_ID"] || "MISSING"}"
    puts "TELEGRAM_POLL_ENABLED: #{ENV.fetch("TELEGRAM_POLL_ENABLED", "true")}"
    puts "TELEGRAM_AUTO_CLEAR_WEBHOOK: #{ENV.fetch("TELEGRAM_AUTO_CLEAR_WEBHOOK", "false")}"
    puts

    puts "=== Cursor ==="
    cursor = TelegramCursor.find_by(name: Telegram::ChannelPoller::CURSOR_NAME)
    if cursor
      puts "last_update_id: #{cursor.last_update_id}"
      puts "updated_at: #{cursor.updated_at}"
    else
      puts "No cursor record found (never polled)"
    end
    puts

    puts "=== Channel Posts ==="
    puts "Total: #{ChannelPost.count}"
    puts "Recent (30 days): #{ChannelPost.recent.count}"
    if (latest = ChannelPost.order(posted_at: :desc).first)
      puts "Latest: #{latest.posted_at} (message_id=#{latest.message_id})"
    end
    puts

    if token.present?
      require "net/http"
      require "json"

      puts "=== Webhook Info ==="
      uri = URI("https://api.telegram.org/bot#{token}/getWebhookInfo")
      response = Net::HTTP.get_response(uri)
      body = JSON.parse(response.body)
      if body["ok"]
        result = body["result"]
        webhook_url = result["url"].to_s
        if webhook_url.empty?
          puts "No webhook set (good — getUpdates should work)"
        else
          puts "WARNING: Active webhook: #{webhook_url}"
          puts "  This BLOCKS getUpdates! Run: bin/rails telegram:clear_webhook"
        end
        puts "Pending update count: #{result["pending_update_count"]}" if result["pending_update_count"]
      else
        puts "API error: #{body["description"]}"
      end
    end
  end

  desc "Delete any active Telegram webhook so getUpdates works"
  task clear_webhook: :environment do
    token = ENV.fetch("TELEGRAM_BOT_TOKEN")

    require "net/http"
    require "json"

    uri = URI("https://api.telegram.org/bot#{token}/deleteWebhook")
    response = Net::HTTP.get_response(uri)
    body = JSON.parse(response.body)

    if body["ok"]
      puts "Webhook cleared successfully."
    else
      puts "Error: #{body["description"]}"
    end
  end

  desc "Reset the Telegram polling cursor to 0"
  task reset_cursor: :environment do
    cursor = TelegramCursor.find_by(name: Telegram::ChannelPoller::CURSOR_NAME)
    if cursor
      old_value = cursor.last_update_id
      cursor.update!(last_update_id: 0)
      puts "Cursor reset: #{old_value} → 0"
    else
      puts "No cursor record found. Nothing to reset."
    end
  end

  desc "Run a single Telegram poll cycle immediately and display results"
  task poll_now: :environment do
    puts "Running a single poll cycle..."
    count = Telegram::ChannelPoller.new.poll_once
    puts "Processed #{count} posts."
    puts
    puts "Recent channel posts (last 5):"
    ChannelPost.order(posted_at: :desc).limit(5).each do |post|
      puts "  [#{post.posted_at}] (msg #{post.message_id}) #{post.text.truncate(80)}"
    end
  end
end
