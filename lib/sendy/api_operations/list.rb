# frozen_string_literal: true

module Sendy
  module APIOperations
    module List
      def list(filters = {}, list_options = {})
        endpoint = list_options[:endpoint]

        resp = request(:get, endpoint || resource_url, filters)

        obj = ListObject.construct_from(data: resp.data,
                                        url: endpoint || resource_url,
                                        operations: list_options[:operations])

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
