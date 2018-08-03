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
      "#{Sendy.app_host}/v1/#{self::OBJECT_NAME.downcase.tr('.', '/')}s"
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
  end
end
