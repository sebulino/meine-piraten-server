class ChannelPostsCleanupJob < ApplicationJob
  queue_as :default

  def perform
    count = ChannelPost.where(posted_at: ...30.days.ago).delete_all
    Rails.logger.info "ChannelPostsCleanupJob: deleted #{count} posts older than 30 days"
  end
end
