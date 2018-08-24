# frozen_string_literal: true

module Sendy
  module APIOperations
    module Request
      module ClassMethods
        def request(method, url, params = {})
          OpenStruct.new(data: JSON.parse(api_request(method, url, params), symbolize_names: true))
        rescue RestClient::NotAcceptable => e
          raise Sendy::InvalidRequestError.new(e.response.to_s)
        rescue RestClient::UnprocessableEntity => e
          JSON.parse(e.response.to_s, symbolize_names: true)
        rescue RestClient::InternalServerError => e
          raise Sendy::InternalAPIError.new
        rescue RestClient::Unauthorized => e
          raise Sendy::AuthenticationError.new(e.response.to_s)
        end

        def api_request(method, url, params = {})
          params.merge!(Sendy.esp_login_params).reject! {|_k, v| v.nil? }
          RestClient::Request.execute(method: method, url: url, payload: params,
                                      headers: { Authorization: "token #{Sendy.user_api_token}" })
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
