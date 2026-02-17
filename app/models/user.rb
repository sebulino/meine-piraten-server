class User < ApplicationRecord
  devise :omniauthable, :trackable,
         omniauth_providers: [:openid_connect]

  has_many :admin_requests

  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :provider, presence: true

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.preferred_username = auth.info.preferred_username || auth.info.nickname
    end.tap do |user|
      user.update(
        email: auth.info.email,
        name: auth.info.name,
        preferred_username: auth.info.preferred_username || auth.info.nickname,
        refresh_token: auth.credentials.refresh_token,
        token_expires_at: auth.credentials.expires_at ? Time.at(auth.credentials.expires_at) : nil
      )
    end
  end
end
