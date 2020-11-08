# frozen_string_literal: true

class CallbacksController < ActionController::API
  def text_message
    HandleCallbackService.process(
      external_id: callback_params[:message_id],
      status: callback_params[:status]
    )

    Notification.find_by(external_id: callback_params[:message_id]).update(status: callback_params[:status])

    render json: {
      number: callback_params[:status],
      message: callback_params[:message_id]
    }, status: :accepted
  end

  private

  def callback_params
    params.require(:callback).permit(:status, :message_id)
  end
end
