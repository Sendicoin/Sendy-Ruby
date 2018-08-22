# frozen_string_literal: true

module Sendy
  class InternalAPIError < StandardError; end
  class InvalidParams < StandardError; end

  module APIOperations
    module Request
      module ClassMethods
        def request(method, url, params = {})
          response = OpenStruct.new(data: JSON.parse(api_request(method, url, params), symbolize_names: true))
        rescue RestClient::NotAcceptable => e
          raise InvalidParams.new(e.response.to_s)
        rescue RestClient::UnprocessableEntity => e
          raise InvalidRequestError.new(e.response.to_s)
        rescue RestClient::InternalServerError => e
          raise InternalAPIError.new
        rescue RestClient::Unauthorized => e
          raise AuthenticationError.new(e.response.to_s)
        end

        def api_request(method, url, params = {})
          params.merge!(Sendy.esp_login_params)
          RestClient::Request.execute(method: method, url: url, payload: params,
                                      headers: { Authorization: "token #{Sendy.app_esp_password}" })
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      protected

      def request(method, url, params = {})
        self.class.request(method, url, params)
      end
    end
  end
end
