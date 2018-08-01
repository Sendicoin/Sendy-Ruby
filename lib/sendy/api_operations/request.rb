# frozen_string_literal: true

module Sendy
  class InternalAPIError < StandardError; end

  module APIOperations
    module Request
      module ClassMethods
        def request(method, url, params = nil)
          response = OpenStruct.new(JSON.parse(api_request(method, url, params)))
        rescue RestClient::NotAcceptable => e
          puts e.response
          raise InvalidParams.new(e.response.to_s)
        rescue RestClient::UnprocessableEntity => e
          message = e.response.to_s
        rescue RestClient::InternalServerError => e
          raise InternalAPIError.new
        end

        def api_request(method, url, params = nil)
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
