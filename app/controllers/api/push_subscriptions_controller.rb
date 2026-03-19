module Api
  class PushSubscriptionsController < ApplicationController
    skip_forgery_protection

    def create
      sub = PushSubscription.find_or_initialize_by(token: params[:token])
      sub.assign_attributes(
        user: current_user_or_api_user,
        platform: params[:platform] || "ios",
        messages_enabled: params[:messages] == true,
        todos_enabled:    params[:todos] == true,
        forum_enabled:    params[:forum] == true,
        news_enabled:     params[:news] == true
      )

      if sub.save
        render json: {}, status: :ok
      else
        render json: { errors: sub.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      sub = PushSubscription.find_by(token: params[:token])
      sub&.destroy
      render json: {}, status: :ok
    end
  end
end
