# frozen_string_literal: true

module Sendy
  module APIOperations
    module NestedResource
      def nested_resource_class_methods(resource, path: nil, operations: nil)
        path ||= "#{resource}s"
        raise ArgumentError, "operations array required" if operations.nil?

        resource_url_method = :"#{resource}s_url"
        define_singleton_method(resource_url_method) do |id, nested_id = nil|
          url = "#{resource_url}/#{CGI.escape(id)}/#{CGI.escape(path)}"
          url += "/#{CGI.escape(nested_id)}" unless nested_id.nil?
          url
        end

        operations.each do |operation|
          case operation
          when :create
            define_singleton_method(:"create_#{resource}") do |id, params = {}|
              url = send(resource_url_method, id)
              resp = request(:post, url, params)
              Util.convert_to_sendy_object(resp.data)
            end
          when :retrieve
            define_singleton_method(:"retrieve_#{resource}") do |id, nested_id|
              url = send(resource_url_method, id, nested_id)
              resp = request(:get, url, {})
              Util.convert_to_sendy_object(resp.data)
            end
          when :update
            define_singleton_method(:"update_#{resource}") do |id, nested_id, params = {}|
              url = send(resource_url_method, id, nested_id)
              resp = request(:post, url, params)
              Util.convert_to_sendy_object(resp.data)
            end
          when :delete
            define_singleton_method(:"delete_#{resource}") do |id, nested_id, params = {}|
              url = send(resource_url_method, id, nested_id)
              resp = request(:delete, url, params)
              Util.convert_to_sendy_object(resp.data)
            end
          when :list
            define_singleton_method(:"list_#{resource}s") do |id, params = {}|
              url = send(resource_url_method, id)
              resp = request(:get, url, params)
              Util.convert_to_sendy_object(resp.data)
            end
          else
            raise ArgumentError, "Unknown operation: #{operation.inspect}"
          end
        end
      end
    end
  end
end
