# frozen_string_literal: true

module Sendy
  module APIOperations
    module Delete
      def delete(params = {})
        resp = request(:delete, resource_url, params)
        if resp&.data
          initialize_from(resp.data)
        else
          Util.convert_to_sendy_object(resp)
        end
      end
    end
  end
end
