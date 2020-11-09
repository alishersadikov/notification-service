# frozen_string_literal: true

module Api
  module V1
    class NotificationsController < ActionController::API
      include Pagy::Backend

      def index
        pagy, records = pagy(Notification.where(search_params))

        serialized_records = NotificationSerializer.new(
          records,
          {
            meta: {
              pagination: pagy_metadata(pagy)
            }
          }
        )

        render json: serialized_records, status: :ok
      end

      def show
        notification = Notification.find(params[:id])

        render json: NotificationSerializer.new(notification).serializable_hash.to_json, status: :ok
      end

      def create
        notification = HandleNotificationRequestService.process(
          number: notification_params[:number],
          message: notification_params[:message]
        )

        render json: NotificationSerializer.new(notification).serializable_hash.to_json, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :bad_request
      end

      private

      def search_params
        params.permit(:number, :message, :status, :external_id)
      end

      def notification_params
        params.require(:notification).permit(:number, :message)
      end
    end
  end
end
