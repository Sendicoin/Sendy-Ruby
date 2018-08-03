# frozen_string_literal: true

module Sendy
  module APIOperations
    module Delete
      def delete(params = {})
        resp = request(:delete, resource_url, params)
        initialize_from(resp.data)
      end
    end
  end
end
