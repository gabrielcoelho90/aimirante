require "rails_helper"

RSpec.describe RefreshToken, type: :model do
  let(:user) { create(:user) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { build(:refresh_token, user: user) }

    it { is_expected.to validate_presence_of(:token_digest) }
    it { is_expected.to validate_uniqueness_of(:token_digest) }
    it { is_expected.to validate_presence_of(:expires_at) }
  end

  describe ".generate_for" do
    it "returns a raw token string and a persisted record" do
      raw_token, record = RefreshToken.generate_for(user)

      expect(raw_token).to be_a(String)
      expect(raw_token.length).to be >= 64
      expect(record).to be_persisted
    end

    it "stores only the digest, never the raw token" do
      raw_token, record = RefreshToken.generate_for(user)

      expect(record.token_digest).not_to eq(raw_token)
      expect(record.token_digest).to eq(Digest::SHA256.hexdigest(raw_token))
    end

    it "sets expiration to 30 days from now" do
      _, record = RefreshToken.generate_for(user)

      expect(record.expires_at).to be_within(5.seconds).of(30.days.from_now)
    end

    it "stores device_fingerprint when provided" do
      _, record = RefreshToken.generate_for(user, device_fingerprint: "fp-abc123")

      expect(record.device_fingerprint).to eq("fp-abc123")
    end
  end

  describe ".find_by_raw_token" do
    it "returns the record matching the raw token" do
      raw_token, record = RefreshToken.generate_for(user)

      expect(RefreshToken.find_by_raw_token(raw_token)).to eq(record)
    end

    it "returns nil for an unknown token" do
      expect(RefreshToken.find_by_raw_token("bogus")).to be_nil
    end
  end

  describe "#active?" do
    it "returns true for a fresh token" do
      _, record = RefreshToken.generate_for(user)
      expect(record.active?).to be true
    end

    it "returns false when expired" do
      _, record = RefreshToken.generate_for(user)
      record.update!(expires_at: 1.second.ago)
      expect(record.active?).to be false
    end

    it "returns false when revoked" do
      _, record = RefreshToken.generate_for(user)
      record.revoke!
      expect(record.active?).to be false
    end
  end

  describe "#revoke!" do
    it "sets revoked_at to the current time" do
      _, record = RefreshToken.generate_for(user)
      record.revoke!
      expect(record.revoked_at).to be_within(5.seconds).of(Time.current)
    end
  end
end
