module Sendy
  module Transaction

    def transactions
      api_call('get', transactions_url).map do |transaction| 
        Transaction.new(OpenStruct.new(transaction))
      end
    end

    def transactions_url
      "#{Sendy.app_host}/api/transactions"
    end

    class Transaction
      include Sendy
      attr_reader :type, :created_at, :update_at, :amount

      def initialize(params)
        @type = params[:type]
        @created_at = params[:created_at]
        @update_at = params[:updated_at]
        @amount = params[:amount]
        @moment_balance = params[:moment_balance]
      end
    end
  end
end
