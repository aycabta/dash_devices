class User < ApplicationRecord
  has_many :devices

  def self.find_or_create_by_auth(auth)
    user = User.find_or_create_by(provider: auth['provider'], uid: auth['uid'])

    user.name = auth['info']['name']
    user.email = auth['info']['email']
    user.token = auth['credentials']['token']
    user.refresh_token = auth['credentials']['refresh_token']

    user.save
    user
  end
end
