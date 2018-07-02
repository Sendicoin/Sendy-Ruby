module Sendy
  class Transactions
    def transactions
      api_call('get', TRANSACTIONS_URL).map { |transaction| OpenStruct.new(transaction) }
    end
  end
end
