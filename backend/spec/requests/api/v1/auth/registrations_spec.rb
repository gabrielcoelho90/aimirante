require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST /api/v1/auth/sign_up" do
    let(:valid_params) do
      {
        user: {
          name: "Oficial de Marinha",
          email: "novo@aimirante.com.br",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    context "with valid params" do
      it "returns HTTP 201" do
        post "/api/v1/auth/sign_up", params: valid_params
        expect(response).to have_http_status(:created)
      end

      it "creates a new user" do
        expect {
          post "/api/v1/auth/sign_up", params: valid_params
        }.to change(User, :count).by(1)
      end

      it "returns an access_token" do
        post "/api/v1/auth/sign_up", params: valid_params
        expect(json["access_token"]).to be_present
      end

      it "returns a refresh_token" do
        post "/api/v1/auth/sign_up", params: valid_params
        expect(json["refresh_token"]).to be_present
      end

      it "returns the user's name and email" do
        post "/api/v1/auth/sign_up", params: valid_params
        expect(json["user"]["name"]).to eq("Oficial de Marinha")
        expect(json["user"]["email"]).to eq("novo@aimirante.com.br")
      end

      it "defaults the plan to trial" do
        post "/api/v1/auth/sign_up", params: valid_params
        expect(json["user"]["plan"]).to eq("trial")
      end
    end

    context "with invalid params" do
      it "returns HTTP 422 when email is taken" do
        create(:user, email: "novo@aimirante.com.br")
        post "/api/v1/auth/sign_up", params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns HTTP 422 when name is missing" do
        post "/api/v1/auth/sign_up",
          params: { user: valid_params[:user].merge(name: "") }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns HTTP 422 when password is too short" do
        post "/api/v1/auth/sign_up",
          params: { user: valid_params[:user].merge(password: "short", password_confirmation: "short") }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns validation errors in the body" do
        post "/api/v1/auth/sign_up",
          params: { user: valid_params[:user].merge(name: "") }
        expect(json["errors"]).to be_present
      end
    end
  end
end
