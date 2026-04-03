require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "validations" do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_length_of(:password).is_at_least(8) }
    it { is_expected.to validate_inclusion_of(:plan).in_array(%w[trial monthly semi_annual annual]) }
  end

  describe "defaults" do
    it "defaults plan to trial" do
      expect(user.plan).to eq("trial")
    end

    it "generates a jti before create" do
      user.save!
      expect(user.jti).to be_present
    end
  end

  describe "#active_subscription?" do
    context "when plan is trial" do
      it "returns false" do
        user.plan = "trial"
        user.plan_expires_at = 7.days.from_now
        expect(user.active_subscription?).to be false
      end
    end

    context "when plan is paid and not expired" do
      it "returns true" do
        user.plan = "monthly"
        user.plan_expires_at = 30.days.from_now
        expect(user.active_subscription?).to be true
      end
    end

    context "when plan is paid but expired" do
      it "returns false" do
        user.plan = "monthly"
        user.plan_expires_at = 1.day.ago
        expect(user.active_subscription?).to be false
      end
    end
  end
end
