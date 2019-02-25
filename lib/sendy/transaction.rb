module Sendy
  module Transaction
    def transactions(args={})
      api_call('get', transactions_url(args)).map do |transaction|
        Transaction.new(OpenStruct.new(transaction))
      end
    end

    def transactions_url(params={})
      "#{Sendy.app_host}/api/transactions?#{params.to_query}"
    end

    class Transaction
      include Sendy
      attr_reader :type, :created_at, :update_at, :amount, :moment_balance

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
