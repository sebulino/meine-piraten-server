module Api
  class NewsController < ApplicationController
    skip_before_action :authenticate_request!

    def index
      limit = [ (params[:limit] || 50).to_i, 200 ].min
      posts = ChannelPost.recent.order(posted_at: :desc).limit(limit)

      render json: posts.map { |p|
        {
          chat_id:    p.chat_id,
          message_id: p.message_id,
          posted_at:  p.posted_at.iso8601,
          text:       p.text
        }
      }
    end
  end
end
