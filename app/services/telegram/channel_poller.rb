require "net/http"
require "json"
require "uri"

module Telegram
  class ChannelPoller
    CURSOR_NAME = "telegram_channel_poller"

    def initialize
      @token   = ENV.fetch("TELEGRAM_BOT_TOKEN")
      @chat_id = Integer(ENV.fetch("TELEGRAM_CHAT_ID"))
      @timeout = ENV.fetch("TELEGRAM_POLL_TIMEOUT", "30").to_i
      @allowed_updates = JSON.parse(
        ENV.fetch("TELEGRAM_ALLOWED_UPDATES", '["channel_post","edited_channel_post"]')
      )
    end

    # Performs a single long-poll cycle and persists new/edited channel posts.
    # Returns the number of processed updates.
    def poll_once
      Rails.logger.info "ChannelPoller: starting poll cycle"
      cursor = TelegramCursor.find_or_create_by!(name: CURSOR_NAME)
      cursor.update!(last_update_id: 0) if cursor.last_update_id.nil?
      offset = cursor.last_update_id + 1

      updates = fetch_updates(offset)
      return 0 if updates.empty?

      max_update_id = cursor.last_update_id
      posts_to_upsert = []

      updates.each do |update|
        update_id = update["update_id"]
        max_update_id = [ max_update_id, update_id ].max

        post = update["channel_post"] || update["edited_channel_post"]
        next if post.nil?

        chat = post["chat"] || post["sender_chat"]
        next if chat.nil?

        chat_id = chat["id"]
        next unless chat_id == @chat_id

        posts_to_upsert << {
          chat_id:    chat["id"],
          message_id: post["message_id"],
          posted_at:  Time.at(post["date"]).utc,
          text:       post["text"] || post["caption"] || "",
          raw_json:   post
        }
      end

      ActiveRecord::Base.transaction do
        posts_to_upsert.each do |attrs|
          ChannelPost
            .create_with(attrs.except(:chat_id, :message_id))
            .find_or_initialize_by(chat_id: attrs[:chat_id], message_id: attrs[:message_id])
            .tap { |cp| cp.assign_attributes(attrs); cp.save! }
        end

        cursor.update!(last_update_id: max_update_id)
      end

      Rails.logger.info "ChannelPoller: processed #{posts_to_upsert.size} posts"
      posts_to_upsert.size
    end

    private

    def fetch_updates(offset)
      uri = URI("https://api.telegram.org/bot#{@token}/getUpdates")
      uri.query = URI.encode_www_form(
        offset: offset,
        timeout: @timeout,
        allowed_updates: JSON.generate(@allowed_updates)
      )

      response = Net::HTTP.get_response(uri)
      body = JSON.parse(response.body)

      unless body["ok"]
        raise "Telegram API error: #{body["description"] || body.inspect}"
      end

      body["result"] || []
    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED, JSON::ParserError => e
      Rails.logger.error "ChannelPoller: fetch_updates failed (#{e.class}): #{e.message}"
      []
    end
  end
end
