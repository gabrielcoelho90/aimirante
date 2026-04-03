class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?

  respond_to :json

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    unless token
      render json: { error: "Token de autenticação ausente." }, status: :unauthorized and return
    end

    payload = Warden::JWTAuth::TokenDecoder.new.call(token)
    user = User.find_by(id: payload["sub"], jti: payload["jti"])
    unless user
      render json: { error: "Token inválido ou expirado." }, status: :unauthorized and return
    end

    @current_user = user
  rescue JWT::DecodeError, JWT::ExpiredSignature
    render json: { error: "Token inválido ou expirado." }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end
end
