module Api
  module V1
    module Auth
      class RegistrationsController < ApplicationController
        def create
          user = User.new(registration_params)

          if user.save
            access_token = generate_access_token(user)
            raw_refresh_token, = RefreshToken.generate_for(
              user,
              device_fingerprint: params[:device_fingerprint]
            )

            render json: {
              access_token: access_token,
              refresh_token: raw_refresh_token,
              expires_in: 1.hour.to_i,
              refresh_token_expires_in: 30.days.to_i,
              user: {
                id: user.id,
                name: user.name,
                email: user.email,
                plan: user.plan,
                plan_expires_at: user.plan_expires_at
              }
            }, status: :created
          else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def registration_params
          params.require(:user).permit(:name, :email, :password, :password_confirmation)
        end

        def generate_access_token(user)
          Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
        end
      end
    end
  end
end
