require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  let(:password) { "password123" }
  let(:user) { create(:user, password: password, password_confirmation: password) }

  describe "POST /api/v1/auth/sign_in" do
    let(:valid_params) do
      { user: { email: user.email, password: password } }
    end

    context "with valid credentials" do
      it "returns HTTP 200" do
        post "/api/v1/auth/sign_in", params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it "returns an access_token in the body" do
        post "/api/v1/auth/sign_in", params: valid_params
        expect(json["access_token"]).to be_present
      end

      it "returns a refresh_token in the body" do
        post "/api/v1/auth/sign_in", params: valid_params
        expect(json["refresh_token"]).to be_present
      end

      it "returns token expiry metadata" do
        post "/api/v1/auth/sign_in", params: valid_params
        expect(json["expires_in"]).to eq(3600)
        expect(json["refresh_token_expires_in"]).to eq(30.days.to_i)
      end

      it "returns basic user data" do
        post "/api/v1/auth/sign_in", params: valid_params
        expect(json["user"]["id"]).to eq(user.id)
        expect(json["user"]["email"]).to eq(user.email)
        expect(json["user"]["name"]).to eq(user.name)
      end

      it "does not expose the password digest" do
        post "/api/v1/auth/sign_in", params: valid_params
        expect(json["user"].keys).not_to include("encrypted_password")
      end

      it "stores device_fingerprint when provided" do
        post "/api/v1/auth/sign_in",
          params: valid_params.merge(device_fingerprint: "fp-abc123")
        expect(RefreshToken.last.device_fingerprint).to eq("fp-abc123")
      end
    end

    context "when signing in from a new device (fingerprint changed)" do
      let(:old_fingerprint) { "fp-old-device" }
      let(:new_fingerprint) { "fp-new-device" }
      let!(:existing_token) { create(:refresh_token, user: user) }

      before { user.update!(active_device_fingerprint: old_fingerprint) }

      it "revokes all previous active refresh tokens" do
        post "/api/v1/auth/sign_in",
          params: valid_params.merge(device_fingerprint: new_fingerprint)
        expect(existing_token.reload.active?).to be false
      end

      it "updates active_device_fingerprint to the new value" do
        post "/api/v1/auth/sign_in",
          params: valid_params.merge(device_fingerprint: new_fingerprint)
        expect(user.reload.active_device_fingerprint).to eq(new_fingerprint)
      end

      it "enqueues a device alert email" do
        expect {
          post "/api/v1/auth/sign_in",
            params: valid_params.merge(device_fingerprint: new_fingerprint)
        }.to have_enqueued_mail(DeviceAlertMailer, :new_device_detected)
      end

      it "still returns HTTP 200 with tokens" do
        post "/api/v1/auth/sign_in",
          params: valid_params.merge(device_fingerprint: new_fingerprint)
        expect(response).to have_http_status(:ok)
        expect(json["access_token"]).to be_present
        expect(json["refresh_token"]).to be_present
      end
    end

    context "when signing in from the same device (fingerprint unchanged)" do
      let(:fingerprint) { "fp-same-device" }
      let!(:existing_token) { create(:refresh_token, user: user, device_fingerprint: fingerprint) }

      before { user.update!(active_device_fingerprint: fingerprint) }

      it "does not revoke previous tokens" do
        post "/api/v1/auth/sign_in",
          params: valid_params.merge(device_fingerprint: fingerprint)
        expect(existing_token.reload.active?).to be true
      end

      it "does not enqueue a device alert email" do
        expect {
          post "/api/v1/auth/sign_in",
            params: valid_params.merge(device_fingerprint: fingerprint)
        }.not_to have_enqueued_mail(DeviceAlertMailer, :new_device_detected)
      end
    end

    context "when signing in without a fingerprint" do
      let!(:existing_token) { create(:refresh_token, user: user) }

      before { user.update!(active_device_fingerprint: "fp-existing") }

      it "does not revoke previous tokens" do
        post "/api/v1/auth/sign_in", params: valid_params
        expect(existing_token.reload.active?).to be true
      end

      it "does not enqueue a device alert email" do
        expect {
          post "/api/v1/auth/sign_in", params: valid_params
        }.not_to have_enqueued_mail(DeviceAlertMailer, :new_device_detected)
      end
    end

    context "when signing in with a fingerprint for the first time" do
      it "stores the fingerprint as active_device_fingerprint" do
        post "/api/v1/auth/sign_in",
          params: valid_params.merge(device_fingerprint: "fp-first")
        expect(user.reload.active_device_fingerprint).to eq("fp-first")
      end

      it "does not enqueue a device alert email" do
        expect {
          post "/api/v1/auth/sign_in",
            params: valid_params.merge(device_fingerprint: "fp-first")
        }.not_to have_enqueued_mail(DeviceAlertMailer, :new_device_detected)
      end
    end

    context "with invalid credentials" do
      it "returns HTTP 401 for wrong password" do
        post "/api/v1/auth/sign_in",
          params: { user: { email: user.email, password: "wrong" } }
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns HTTP 401 for unknown email" do
        post "/api/v1/auth/sign_in",
          params: { user: { email: "nobody@aimirante.com.br", password: password } }
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        post "/api/v1/auth/sign_in",
          params: { user: { email: user.email, password: "wrong" } }
        expect(json["error"]).to be_present
      end
    end
  end

  describe "POST /api/v1/auth/refresh" do
    let!(:raw_token) do
      token, = RefreshToken.generate_for(user)
      token
    end

    context "with a valid refresh token" do
      it "returns HTTP 200" do
        post "/api/v1/auth/refresh", params: { refresh_token: raw_token }
        expect(response).to have_http_status(:ok)
      end

      it "returns a new access_token" do
        post "/api/v1/auth/refresh", params: { refresh_token: raw_token }
        expect(json["access_token"]).to be_present
      end

      it "returns a new refresh_token (rotation)" do
        post "/api/v1/auth/refresh", params: { refresh_token: raw_token }
        expect(json["refresh_token"]).to be_present
        expect(json["refresh_token"]).not_to eq(raw_token)
      end

      it "revokes the old refresh token after rotation" do
        post "/api/v1/auth/refresh", params: { refresh_token: raw_token }
        old_record = RefreshToken.find_by_raw_token(raw_token)
        expect(old_record.active?).to be false
      end

      it "returns expires_in metadata" do
        post "/api/v1/auth/refresh", params: { refresh_token: raw_token }
        expect(json["expires_in"]).to eq(3600)
      end
    end

    context "with an invalid refresh token" do
      it "returns HTTP 401 for unknown token" do
        post "/api/v1/auth/refresh", params: { refresh_token: "bogus" }
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns HTTP 401 for an expired token" do
        _, record = RefreshToken.generate_for(user)
        record.update!(expires_at: 1.second.ago)
        expired_token = "sometoken"
        allow(RefreshToken).to receive(:find_by_raw_token).and_return(record)

        post "/api/v1/auth/refresh", params: { refresh_token: expired_token }
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns HTTP 401 for a revoked token" do
        _, record = RefreshToken.generate_for(user)
        record.revoke!
        revoked_raw = "revokedtoken"
        allow(RefreshToken).to receive(:find_by_raw_token).and_return(record)

        post "/api/v1/auth/refresh", params: { refresh_token: revoked_raw }
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        post "/api/v1/auth/refresh", params: { refresh_token: "bogus" }
        expect(json["error"]).to be_present
      end
    end
  end

  describe "DELETE /api/v1/auth/sign_out" do
    let(:access_token) do
      post "/api/v1/auth/sign_in",
        params: { user: { email: user.email, password: password } }
      json["access_token"]
    end

    let(:refresh_token) do
      post "/api/v1/auth/sign_in",
        params: { user: { email: user.email, password: password } }
      json["refresh_token"]
    end

    it "returns HTTP 200" do
      token = access_token
      delete "/api/v1/auth/sign_out",
        headers: { "Authorization" => "Bearer #{token}" }
      expect(response).to have_http_status(:ok)
    end

    it "revokes the refresh token" do
      rt = refresh_token
      at = json["access_token"]
      delete "/api/v1/auth/sign_out",
        headers: { "Authorization" => "Bearer #{at}" },
        params: { refresh_token: rt }
      expect(RefreshToken.find_by_raw_token(rt).active?).to be false
    end

    it "returns HTTP 401 when no token is provided" do
      delete "/api/v1/auth/sign_out"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
