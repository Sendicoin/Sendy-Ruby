module Sendy
  class Campaign < APIResource
    extend Sendy::APIOperations::List
    include Sendy::APIOperations::Save
    include Sendy::APIOperations::Delete
    extend Sendy::APIOperations::Create

    OBJECT_NAME= 'campaign'.freeze
  end
end
