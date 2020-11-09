# frozen_string_literal: true

module Api
  module V1
    class ProvidersController < ActionController::API
      def index
        providers = ProviderSerializer.new(Provider.all).serializable_hash.to_json

        render json: providers, status: :ok
      end

      def show
        provider = Provider.find(params[:id])

        render json: ProviderSerializer.new(provider).serializable_hash.to_json, status: :ok
      end

      def create
        provider = Provider.new(url: provider_params[:url], weight: provider_params[:weight])

        if provider.save
          render json: ProviderSerializer.new(provider).serializable_hash.to_json, status: :ok
        else
          render json: { error: provider.errors.full_messages.join(', ') }, status: :bad_request
        end
      end

      private

      def provider_params
        params.require(:provider).permit(:url, :weight)
      end
    end
  end
end
