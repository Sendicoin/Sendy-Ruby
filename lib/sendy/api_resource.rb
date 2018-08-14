# frozen_string_literal: true

module Sendy
  class APIResource < SendyObject
    include Sendy::APIOperations::Request

    attr_accessor :save_with_parent

    def self.class_name
      name.split("::")[-1]
    end

    def self.resource_url
      if self == APIResource
        raise NotImplementedError, "APIResource is an abstract class.  You should perform actions on its subclasses"
      end
      # Namespaces are separated in object names with periods (.) and in URLs
      # with forward slashes (/), so replace the former with the latter.
      "#{Sendy.app_host}/api/v1/#{self::OBJECT_NAME.downcase.tr('.', '/')}s"
    end

    def self.resource_count_url
      "#{resource_url}/count.json"
    end

    # endpoint when request comes from parent resource
    # like an user requesting campaigns should request
    # /users/:user_id/campaigns instead of /campaigns
    def self.resource_endpoint(id, source = 'user')
      "#{Sendy.app_host}/api/v1/#{source}s/#{id}/#{self::OBJECT_NAME}s"
    end

    def self.save_nested_resource(name)
      define_method(:"#{name}=") do |value|
        super(value)

        value = send(name)
        value.save_with_parent = true if value.is_a?(APIResource)
        value
      end
    end

    def resource_url
      unless (id = self["id"])
        raise InvalidRequestError, "Could not determine which URL to request: #{self.class} instance has invalid ID: #{id.inspect}"
      end
      "#{self.class.resource_url}/#{CGI.escape(id.to_s)}"
    end

    def refresh
      resp = request(:get, resource_url, @retrieve_params)
      initialize_from(resp.data)
    end

    def self.retrieve(id)
      instance = new(id)
      instance.refresh
      instance
    end

    def self.find(id)
      retrieve(id)
    end
  end
end
