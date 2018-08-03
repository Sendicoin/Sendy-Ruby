# frozen_string_literal: true

module Sendy
  module APIOperations
    module List
      def list(filters = {})
        resp = request(:get, resource_url, filters)
        resp.url = if resp.source
                     "#{Sendy.app_host}/#{resp.source}s/#{resp.source_uid}/#{self::OBJECT_NAME}s"
                   else
                     "#{Sendy.app_host}/#{self::OBJECT_NAME}s"
                   end

        obj = ListObject.construct_from(resp.data)

        # set filters so that we can fetch the same limit, expansions, and
        # predicates when accessing the next and previous pages
        #
        # just for general cleanliness, remove any paging options
        obj.filters = filters.dup
        obj.filters.delete(:ending_before)
        obj.filters.delete(:starting_after)

        obj
      end

      alias all list
    end
  end
end
