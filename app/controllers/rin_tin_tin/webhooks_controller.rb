require_dependency "rin_tin_tin/application_controller"

module RinTinTin
  class WebhooksController < ApplicationController

    def index
      render text: 'works'
    end

    def create
      hook = Webhook.new
      hook.sender = request.symbolized_path_parameters[:sender]
      hook.body = request.raw_post || (request.body.rewind && request.body.read)
      hook.request_params = request.request_parameters
      hook.query_string = request.query_string
      hook.query_params = request.query_parameters
      hook.timestamp = Time.now.to_i
      hook.referrer = request.referrer
      hook.method = request.method
      hook.path = request.path

      hook.headers = clean_headers
      if hook.save
        render nothing: true, status: :ok
      else
        render json: {error: "Could not save webhook"}, status: :unprocessable_entity
      end
    end

    private

    def clean_headers
      headers = {}
      request.env.select { |k,v| k.start_with? 'HTTP_' }
        .each { |k, v| headers[k.sub(/^HTTP_/, '')] = v }
      headers
    end

  end
end
