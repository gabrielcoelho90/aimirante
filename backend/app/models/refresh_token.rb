class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  def self.generate_for(user, device_fingerprint: nil)
    raw_token = SecureRandom.hex(32)
    record = create!(
      user: user,
      token_digest: Digest::SHA256.hexdigest(raw_token),
      expires_at: 30.days.from_now,
      device_fingerprint: device_fingerprint
    )
    [ raw_token, record ]
  end

  def self.find_by_raw_token(raw_token)
    find_by(token_digest: Digest::SHA256.hexdigest(raw_token))
  end

  def active?
    revoked_at.nil? && expires_at.future?
  end

  def revoke!
    update!(revoked_at: Time.current)
  end
end
