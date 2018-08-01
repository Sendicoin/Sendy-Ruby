# frozen_string_literal: true

module Sendy
  class Util
    def self.convert_to_sendy_object(data)
      case data
      when Array
        data.map { |i| convert_to_sendy_object(i) }
      when Hash
        # Try converting to a known object class.  If none available, fall back to generic StripeObject
        object_classes.fetch(data[:object], SendyObject).construct_from(data)
      else
        data
      end
    end

    def self.object_classes
      @object_classes ||= {
        # list object
        ListObject::OBJECT_NAME  => ListObject,
        # business objects
        Campaign::OBJECT_NAME    => Campaign,
        Event::OBJECT_NAME       => Event,
        Subscriber::OBJECT_NAME  => Subscriber,
        Transaction::OBJECT_NAME => Transaction,
        User::OBJECT_NAME        => User
      }
    end

    def self.normalize_id(id)
      if id.is_a?(Hash) # overloaded id
        params_hash = id.dup
        id = params_hash.delete(:id)
      else
        params_hash = {}
      end
      [id, params_hash]
    end

    def self.symbolize_names(object)
      case object
      when Hash
        new_hash = {}
        object.each do |key, value|
          key = (begin
                 key.to_sym
        rescue StandardError
          key
        end) || key
        new_hash[key] = symbolize_names(value)
      end
      new_hash
    when Array
      object.map { |value| symbolize_names(value) }
    else
      object
    end
  end
  end
end
