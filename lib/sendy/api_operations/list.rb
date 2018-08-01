# frozen_string_literal: true

module Sendy
  module APIOperations
    module List
      def list(filters = {})
        resp = request(:get, resource_url, filters)
        Util.convert_to_sendy_object(resp.data)
      end

      alias all list
    end
  end
end
