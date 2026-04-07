class DeviceAlertMailer < ApplicationMailer
  default from: "noreply@aimirante.com.br"

  def new_device_detected(user)
    @user = user
    mail(
      to: user.email,
      subject: "Novo acesso detectado na sua conta AI.mirante"
    )
  end
end
