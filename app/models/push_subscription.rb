class PushSubscription < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :platform, presence: true
end
