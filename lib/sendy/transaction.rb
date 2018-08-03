module Sendy
  class Transaction < APIResource
    extend Sendy::APIOperations::List
    extend Sendy::APIOperations::Create
    include Sendy::APIOperations::Save

    OBJECT_NAME = 'transaction'.freeze
  end
end
