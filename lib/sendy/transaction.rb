module Sendy
  module Transaction
    def transactions(params={})
      api_call('get', transactions_url, params).map do |transaction|
        Transaction.new(transaction)
      end
    end

    def transactions_count(params={})
      api_call('get', "#{transactions_url}/count", params)['count'].to_i
    end


    def transactions_url
      "#{Sendy.app_host}//api/v1/transactions"
    end

    class Transaction
      include Sendy
      attr_reader :type, :created_at, :update_at, :amount, :moment_balance

      def initialize(args)
        args.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
