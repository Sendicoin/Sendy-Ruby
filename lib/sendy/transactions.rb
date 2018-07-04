module Sendy
  class Transactions < SendyApi
    def transactions
      api_call('get', TRANSACTIONS_URL).map { |transaction| OpenStruct.new(transaction) }
    end
  end
end
