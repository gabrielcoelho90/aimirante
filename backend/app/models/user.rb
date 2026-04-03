class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  include Devise::JWT::RevocationStrategies::JTIMatcher

  has_many :refresh_tokens, dependent: :destroy

  PLANS = %w[trial monthly semi_annual annual].freeze

  validates :name, presence: true
  validates :plan, inclusion: { in: PLANS }

  def active_subscription?
    plan != "trial" && plan_expires_at.present? && plan_expires_at.future?
  end
end
