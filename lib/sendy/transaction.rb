module Sendy
  class Transaction < APIResource
    extend  Sendy::APIOperations::List
    OBJECT_NAME = 'transaction'.freeze
  end
end
