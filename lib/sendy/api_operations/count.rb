# frozen_string_literal: true

module Sendy
  module APIOperations
    module Count
      def count
        resp = request(:get, resource_count_url)
        resp.data[:count]
      end
    end
  end
end
