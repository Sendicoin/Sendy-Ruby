# frozen_string_literal: true

module Sendy
  module APIOperations
    module Create
      def create(params = {})
        resp = request(:post, resource_url, params)
        Util.convert_to_sendy_object(resp.data)
      end
    end
  end
end
