module Sendy
  module Transaction
    include Sendy
    def transactions
      api_call('get', TRANSACTIONS_URL).map { |transaction| OpenStruct.new(transaction) }
    end
  end
end
