# frozen_string_literal: true

module Sendy
  module APIOperations
    module Count
      def count(params = {})
        resp = request(:get, resource_count_url, params)
        resp.data[:count]
      end
    end
  end
end
