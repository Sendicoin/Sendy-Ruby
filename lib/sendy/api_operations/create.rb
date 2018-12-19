# frozen_string_literal: true

module Sendy
  module APIOperations
    module Create
      def create(params = {})
        resp = request(:post, resource_url, params)
        if resp&.data
          Util.convert_to_sendy_object(resp.data)
        else
          Util.convert_to_sendy_object(resp)
        end
      end
    end
  end
end
