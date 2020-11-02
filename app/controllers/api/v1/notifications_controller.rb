# frozen_string_literal: true
class Api::V1::NotificationsController < ActionController::API
  def create
    LoadBalancerService.process(
      number: notification_params[:number],
      message: notification_params[:message]
    )
  end

  private

  def notification_params
    params.require(:notification).permit(:number, :message)
  end
end
