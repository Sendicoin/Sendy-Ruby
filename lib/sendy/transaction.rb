module Sendy
  module Transaction

    def transactions
      api_call('get', TRANSACTIONS_URL).map do |transaction| 
        Transaction.new(OpenStruct.new(transaction))
      end
    end

    class Transaction
      include Sendy
      attr_reader :type, :created_at, :update_at, :amount

      def initialize(params)
        @type = params[:type]
        @created_at = params[:created_at]
        @update_at = params[:updated_at]
        @amount = params[:amount]
      end
    end
  end
end
