# frozen_string_literal: true

require 'spec_helper'

describe Sendy::Transaction do
  before do
    Sendy.app_host = 'http://localhost:3000'
    Sendy.app_esp_password = 'valid_api_token'

    stub_request(:get, "http://localhost:3000/api/v1/transactions")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(data: [transaction_fixture]))

    stub_request(:get, "http://localhost:3000/api/v1/transactions/1")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(transaction_fixture))
  end

  it "is listable" do
    transactions = Sendy::Transaction.list
    assert_requested :get, "#{Sendy.app_host}/api/v1/transactions"
    expect(transactions.data.is_a?(Array)).to be true
    expect(transactions.first.is_a?(Sendy::Transaction)).to be true
  end

  it "is retrievable" do
    transaction = Sendy::Transaction.retrieve("1")
    assert_requested :get, "#{Sendy.app_host}/api/v1/transactions/1"
    expect(transaction.is_a?(Sendy::Transaction))
  end

  it "is not creatable" do
    expect { Sendy::Transaction.create }.to raise_error(NotImplementedError)
    assert_not_requested :post, "#{Sendy.app_host}/api/v1/transactions"
  end

  it "is not saveable" do
    transaction = Sendy::Transaction.retrieve("1")
    transaction.event = "other_event_type"
    expect { transaction.save }.to raise_error(NotImplementedError)
  end

  it "is not updateable" do
    expect do
      Sendy::Transaction.update("1", email: "other")
    end.to raise_error(NotImplementedError)
  end

  it "is not deletable" do
    transaction = Sendy::Transaction.retrieve("1")
    expect { transaction.delete }.to raise_error(NotImplementedError)
  end
end
