module Api
  module V1
    module Auth
      class SessionsController < ApplicationController
        before_action :authenticate_user!, only: :destroy

        def create
          user = User.find_by(email: sign_in_params[:email])

          unless user&.valid_password?(sign_in_params[:password])
            render json: { error: "E-mail ou senha inválidos." }, status: :unauthorized and return
          end

          access_token = generate_access_token(user)
          raw_refresh_token, = RefreshToken.generate_for(
            user,
            device_fingerprint: params[:device_fingerprint]
          )

          render json: sign_in_response(user, access_token, raw_refresh_token), status: :ok
        end

        def refresh
          record = RefreshToken.find_by_raw_token(params[:refresh_token].to_s)

          unless record&.active?
            render json: { error: "Refresh token inválido ou expirado." }, status: :unauthorized and return
          end

          user = record.user
          record.revoke!

          access_token = generate_access_token(user)
          new_raw_refresh_token, = RefreshToken.generate_for(user, device_fingerprint: record.device_fingerprint)

          render json: {
            access_token: access_token,
            refresh_token: new_raw_refresh_token,
            expires_in: 1.hour.to_i
          }, status: :ok
        end

        def destroy
          record = RefreshToken.find_by_raw_token(params[:refresh_token].to_s)
          record&.revoke!

          current_user.update!(jti: SecureRandom.uuid)

          render json: { message: "Logout realizado com sucesso." }, status: :ok
        end

        private

        def sign_in_params
          params.require(:user).permit(:email, :password)
        end

        def generate_access_token(user)
          Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
        end

        def sign_in_response(user, access_token, refresh_token)
          {
            access_token: access_token,
            refresh_token: refresh_token,
            expires_in: 1.hour.to_i,
            refresh_token_expires_in: 30.days.to_i,
            user: {
              id: user.id,
              name: user.name,
              email: user.email,
              plan: user.plan,
              plan_expires_at: user.plan_expires_at
            }
          }
        end
      end
    end
  end
end
