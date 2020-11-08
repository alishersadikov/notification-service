# frozen_string_literal: true

module Api
  module V1
    class NotificationsController < ActionController::API
      def create
        HandleNotificationRequestService.process(
          number: notification_params[:number],
          message: notification_params[:message]
        )

        render json: {
          number: notification_params[:number],
          message: notification_params[:message]
        }, status: :accepted
      end

      private

      def notification_params
        params.require(:notification).permit(:number, :message)
      end
    end
  end
end
