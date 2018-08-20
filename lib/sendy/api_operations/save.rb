# frozen_string_literal: true

module Sendy
  module APIOperations
    module Save
      module ClassMethods
        def update(id, params = {})
          params.each_key do |k|
            if protected_fields.include?(k)
              raise ArgumentError, "Cannot update protected field: #{k}"
            end
          end

          resp = request(:put, "#{resource_url}/#{id}", params)
          Util.convert_to_sendy_object(resp.data)
        end
      end

      def save(params = {})
        update_attributes(params)

        params = params.reject { |k, _| respond_to?(k) }

        values = serialize_params(self).merge(params)

        values.delete(:id)


        resp = request(:post, save_url, values)
        initialize_from(resp.data)
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      private

      def save_url
        if self[:id].nil? && self.class.respond_to?(:create)
          self.class.resource_url
        else
          resource_url
        end
      end
    end
  end
end
