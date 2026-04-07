require "rails_helper"

RSpec.describe DeviceAlertMailer, type: :mailer do
  describe "#new_device_detected" do
    let(:user) { create(:user, name: "Oficial Silva", email: "oficial@marinha.mil.br") }
    let(:mail) { described_class.new_device_detected(user) }

    it "sends to the user's email address" do
      expect(mail.to).to eq(["oficial@marinha.mil.br"])
    end

    it "sends from the platform address" do
      expect(mail.from).to eq(["noreply@aimirante.com.br"])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Novo acesso detectado na sua conta AI.mirante")
    end

    it "includes the user's name in the body" do
      expect(mail.body.encoded).to include("Oficial Silva")
    end
  end
end
