# frozen_string_literal: true

module Sendy
  class ListObject < SendyObject
    include Enumerable
    include Sendy::APIOperations::List
    include Sendy::APIOperations::Request
    include Sendy::APIOperations::Create

    OBJECT_NAME = 'list'

    # This accessor allows a `ListObject` to inherit various filters that were
    # given to a predecessor. This allows for things like consistent limits,
    # expansions, and predicates as a user pages through resources.
    attr_accessor :filters

    # An empty list object. This is returned from +next+ when we know that
    # there isn't a next page in order to replicate the behavior of the API
    # when it attempts to return a page beyond the last.
    def self.empty_list
      ListObject.construct_from(data: [])
    end

    def initialize(*args)
      super
      self.filters = {}
    end

    def [](key)
      case key
      when String, Symbol
        super
      else
        raise ArgumentError, "You tried to access the #{key.inspect} index, but " \
          'ListObject types only support String keys. (HINT: List calls return an' \
          " object with a 'data' (which is the data array). You likely want to call" \
          " #data[#{key.inspect}])"
      end
    end

    def find(uid)
      data.select { |obj| obj.uid.to_s == uid.to_s }.first
    end

    def self.list(filters = {}, list_options = {})
      return super(filters, list_options) if operations.nil? || operations.empty? ||
                                             operations.include?(:list)
      raise InvalidRequestError, 'This resource cannot be created'
    end

    def create(params = {})
      return super(params) if operations.nil? || operations.empty? ||
                              operations.include?(:create)
      raise InvalidRequestError, 'This resource cannot be created'
    end

    # Iterates through each resource in the page represented by the current
    # `ListObject`.
    #
    # Note that this method makes no effort to fetch a new page when it gets to
    # the end of the current page's resources. See also +auto_paging_each+.
    def each(&blk)
      data.each(&blk)
    end

    # Iterates through each resource in all pages, making additional fetches to
    # the API as necessary.
    #
    # Note that this method will make as many API calls as necessary to fetch
    # all resources. For more granular control, please see +each+ and
    # +next_page+.
    def auto_paging_each(&blk)
      return enum_for(:auto_paging_each) unless block_given?

      page = self
      loop do
        page.each(&blk)
        page = page.next_page
        break if page.empty?
      end
    end

    # Returns true if the page object contains no elements.
    def empty?
      data.empty?
    end

    def retrieve(id)
      id, retrieve_params = Util.normalize_id(id)
      resp = request(:get, "#{resource_url}/#{CGI.escape(id)}", retrieve_params)
      Util.convert_to_sendy_object(resp.data)
    end

    # Fetches the next page in the resource list (if there is one).
    #
    # This method will try to respect the limit of the current page. If none
    # was given, the default limit will be fetched again.
    def next_page(params = {})
      return self.class.empty_list unless has_more
      last_id = data.last.id

      params = filters.merge(starting_after: last_id).merge(params)

      list(params)
    end

    # Fetches the previous page in the resource list (if there is one).
    #
    # This method will try to respect the limit of the current page. If none
    # was given, the default limit will be fetched again.
    def previous_page(params = {})
      first_id = data.first.id

      params = filters.merge(ending_before: first_id).merge(params)

      list(params)
    end

    def resource_url
      url ||
        raise(ArgumentError, "List object does not contain a 'url' field.")
    end

    def self.protected_fields
      [:url, :operations]
    end
  end
end
