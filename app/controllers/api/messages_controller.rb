module Api
  class MessagesController < ApplicationController
    skip_forgery_protection

    def index
      messages = current_user_or_api_user.received_messages
        .order(created_at: :desc)
        .limit(50)

      render json: messages.map { |m|
        {
          id: m.id,
          sender_id: m.sender_id,
          body: m.body,
          read: m.read,
          created_at: m.created_at.iso8601
        }
      }
    end

    def create
      message = current_user_or_api_user.sent_messages.build(
        recipient_id: params[:recipient_id],
        body: params[:body]
      )

      if message.save
        render json: { id: message.id }, status: :created
      else
        render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      message = current_user_or_api_user.received_messages.find_by(id: params[:id])
      if message.nil?
        render json: { error: "Not found" }, status: :not_found
        return
      end

      message.update!(read: true)
      render json: {}, status: :ok
    end
  end
end
