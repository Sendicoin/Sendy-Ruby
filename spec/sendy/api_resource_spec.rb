# frozen_string_literal: true

require 'spec_helper'

describe Sendy::APIResource do
  class NestedTestAPIResource < Sendy::APIResource
    save_nested_resource :campaign
  end

  before do
    Sendy.app_host = 'localhost:3000'
  end

  context ".save_nested_resource" do
    it "can have a scalar set" do
      r = NestedTestAPIResource.new("test_resource")
      r.campaign = "tok_123"
      expect(r.campaign).to eql(r.campaign)
    end

    it "set a flag if given an object source" do
      r = NestedTestAPIResource.new("test_resource")
      r.campaign = {
        object: "campaign",
      }
      expect(r.campaign.save_with_parent).to be true
    end
  end

  it "creating a new APIResource should not fetch over the network" do
    Sendy::User.new("someid")
    assert_not_requested :get, %r{#{Sendy.app_host}/.*}
  end

  it "creating a new APIResource from a hash should not fetch over the network" do
    Sendy::User.construct_from(id: "someuser",
                               campaign: { id: "somecampaign", object: "campaign" },
                               object: "user")
    assert_not_requested :get, %r{#{Sendy.app_host}/.*}
  end

  it "setting an attribute should not cause a network request" do
    c = Sendy::User.new("cus_123")
    c.campaign = { id: "somecampaign", object: "campaign" }
    assert_not_requested :get, %r{#{Sendy.app_host}/.*}
    assert_not_requested :post, %r{#{Sendy.app_host}/.*}
  end

  it "accessing id should not issue a fetch" do
    c = Sendy::User.new("cus_123")
    c.id
    assert_not_requested :get, %r{#{Sendy.app_host}/.*}
  end

  context 'wrong credentials' do
    it "not specifying api credentials should raise an exception" do
      Sendy.app_esp_password = nil
      expect { Sendy::User.new("cus_123").refresh }.to raise_error(Sendy::AuthenticationError)
    end
  end

  context "with valid credentials" do
    before do
      Sendy.app_esp_password = 'valid_api_token'
    end

    it "urlencode values in GET params" do
      stub_request(:get, "http://localhost:3000/v1/transactions").
        with(
          body: {"user"=>"1"},
          headers: {
            'Authorization'=>'token valid_api_token',
          }).
          to_return(body: JSON.generate(data: [transaction_fixture]))
      transactions = Sendy::Transaction.list(user: "1")
      expect(transactions.is_a? Array).to be true
    end

    it "requesting with a unicode ID should result in a request" do
      stub_request(:get, "#{Sendy.app_host}/v1/users/%E2%98%83")
        .to_return(body: JSON.generate(make_missing_id_error), status: 404)
      c = Sendy::User.new("☃")
      expect { c.refresh }.to raise_error(Sendy::InvalidRequestError)
    end

    it "requesting with no ID should result in an InvalidRequestError with no request" do
      c = Sendy::User.new
      expect { c.refresh }.to raise_error(Sendy::InvalidRequestError)
    end

    it "making a GET request with parameters should have a query string and no body" do
      stub_request(:get, "#{Sendy.app_host}/v1/transactions")
        .with(query: { limit: 1 })
        .to_return(body: JSON.generate(data: [transaction_fixture]))
      Sendy::transaction.list(limit: 1)
    end

    it "making a POST request with parameters should have a body and no query string" do
      stub_request(:post, "#{Sendy.app_host}/v1/transactions")
        .with(body: { "amount" => "100", "currency" => "usd", "campaign" => "sc_token" })
        .to_return(body: JSON.generate(transaction_fixture))
      Sendy::Transaction.create(amount: 100, currency: "usd", campaign: "sc_token")
    end

    it "loading an object should issue a GET request" do
      stub_request(:get, "#{Sendy.app_host}/v1/transactions/ch_123")
        .to_return(body: JSON.generate(transaction_fixture))
      c = Sendy::transaction.new("ch_123")
      c.refresh
    end

    it "using array accessors should be the same as the method interface" do
      stub_request(:get, "#{Sendy.app_host}/v1/transactions/ch_123")
        .to_return(body: JSON.generate(transaction_fixture))
      c = Sendy::transaction.new("cus_123")
      c.refresh
      expect(c.created).to eql c[:created]
      expect(c.created).to eql c['created']
      c["created"] = 12_345
      expect(c.created).to eql 12_345
    end

    it "accessing a property other than id or parent on an unfetched object should fetch it" do
      stub_request(:get, "#{Sendy.app_host}/v1/transactions")
        .with(query: { user: "cus_123" })
        .to_return(body: JSON.generate(user_fixture))
      c = Sendy::User.new("cus_123")
      c.transactions
    end

    it "updating an object should issue a POST request with only the changed properties" do
      stub_request(:post, "#{Sendy.app_host}/v1/users/cus_123")
        .with(body: { "description" => "another_mn" })
        .to_return(body: JSON.generate(user_fixture))
      c = Sendy::User.construct_from(user_fixture)
      c.description = "another_mn"
      c.save
    end

    it "updating should merge in returned properties" do
      stub_request(:post, "#{Sendy.app_host}/v1/users/cus_123")
        .with(body: { "description" => "another_mn" })
        .to_return(body: JSON.generate(user_fixture))
      c = Sendy::User.new("cus_123")
      c.description = "another_mn"
      c.save
      expect(c.another_user_property).to eql false
    end

    it "deleting should send no props and result in an object that has no props other deleted" do
      stub_request(:delete, "#{Sendy.app_host}/v1/users/cus_123")
        .to_return(body: JSON.generate("id" => "cus_123", "deleted" => true))
      c = Sendy::User.construct_from(user_fixture)
      c.delete
    end

    it "loading all of an APIResource should return an array of recursively instantiated objects" do
      stub_request(:get, "#{Sendy.app_host}/v1/transactions")
        .to_return(body: JSON.generate(data: [transaction_fixture]))
      transactions = Sendy::Transaction.list.data
      expect(transactions.is_a?).to eql Array
      expect(transactions[0].is_a?).to eql Sendy::Transaction
      expect(transactions[0].source.is_a?).to eql Sendy::SendyObject
    end

    it "add key to nested objects" do
      acct = Sendy::Account.construct_from(id: "myid",
                                           legal_entity: {
        size: "l",
        score: 4,
        height: 10,
      })

      stub_request(:post, "#{Sendy.app_host}/v1/accounts/myid")
        .with(body: { legal_entity: { first_name: "Bob" } })
        .to_return(body: JSON.generate("id" => "myid"))

      acct.legal_entity.first_name = "Bob"
      acct.save
    end

    it "save nothing if nothing changes" do
      acct = Sendy::Account.construct_from(id: "acct_id",
                                           metadata: {
        key: "value",
      })

      stub_request(:post, "#{Sendy.app_host}/v1/accounts/acct_id")
        .with(body: {})
        .to_return(body: JSON.generate("id" => "acct_id"))

      acct.save
    end

    it "not save nested API resources" do
      ch = Sendy::Transaction.construct_from(id: "ch_id",
                                        user: {
        object: "user",
        id: "user_id",
      })

      stub_request(:post, "#{Sendy.app_host}/v1/transactions/ch_id")
        .with(body: {})
        .to_return(body: JSON.generate("id" => "ch_id"))

      ch.user.description = "Bob"
      ch.save
    end

    it "correctly handle replaced nested objects" do
      acct = Sendy::Account.construct_from(id: "myid",
                                           legal_entity: {
        last_name: "Smith",
        address: {
          line1: "test",
          city: "San Francisco",
        },
      })

      stub_request(:post, "#{Sendy.app_host}/v1/accounts/myid")
        .with(body: { legal_entity: { address: { line1: "Test2", city: "" } } })
        .to_return(body: JSON.generate("id" => "my_id"))

      acct.legal_entity.address = { line1: "Test2" }
      acct.save
    end

    it "correctly handle array setting" do
      acct = Sendy::Account.construct_from(id: "myid",
                                           legal_entity: {})

      stub_request(:post, "#{Sendy.app_host}/v1/accounts/myid")
        .with(body: { legal_entity: { additional_owners: [{ first_name: "Bob" }] } })
        .to_return(body: JSON.generate("id" => "myid"))

      acct.legal_entity.additional_owners = [{ first_name: "Bob" }]
      acct.save
    end

    it "correctly handle array insertion" do
      acct = Sendy::Account.construct_from(id: "myid",
                                           legal_entity: {
        additional_owners: [],
      })

      # Note that this isn't a perfect check because we're using webmock's
      # data decoding, which isn't aware of the Sendy array encoding that we
      # use here.
      stub_request(:post, "#{Sendy.app_host}/v1/accounts/myid")
        .with(body: { legal_entity: { additional_owners: [{ first_name: "Bob" }] } })
        .to_return(body: JSON.generate("id" => "myid"))

      acct.legal_entity.additional_owners << { first_name: "Bob" }
      acct.save
    end

    it "correctly handle array updates" do
      acct = Sendy::Account.construct_from(id: "myid",
                                           legal_entity: {
        additional_owners: [{ first_name: "Bob" }, { first_name: "Jane" }],
      })

      # Note that this isn't a perfect check because we're using webmock's
      # data decoding, which isn't aware of the Sendy array encoding that we
      # use here.
      stub_request(:post, "#{Sendy.app_host}/v1/accounts/myid")
        .with(body: { legal_entity: { additional_owners: [{ first_name: "Janet" }] } })
        .to_return(body: JSON.generate("id" => "myid"))

      acct.legal_entity.additional_owners[1].first_name = "Janet"
      acct.save
    end

    it "correctly handle array noops" do
      acct = Sendy::Account.construct_from(id: "myid",
                                           legal_entity: {
        additional_owners: [{ first_name: "Bob" }],
      },
      currencies_supported: %w[usd cad])

      stub_request(:post, "#{Sendy.app_host}/v1/accounts/myid")
        .with(body: {})
        .to_return(body: JSON.generate("id" => "myid"))

      acct.save
    end

    it "correctly handle hash noops" do
      acct = Sendy::Account.construct_from(id: "myid",
                                           legal_entity: {
        address: { line1: "1 Two Three" },
      })

      stub_request(:post, "#{Sendy.app_host}/v1/accounts/myid")
        .with(body: {})
        .to_return(body: JSON.generate("id" => "myid"))

      acct.save
    end

    it "should create a new resource when an object without an id is saved" do
      account = Sendy::Account.construct_from(id: nil,
                                              display_name: nil)

      stub_request(:post, "#{Sendy.app_host}/v1/accounts")
        .with(body: { display_name: "sendy" })
        .to_return(body: JSON.generate("id" => "acct_123"))

      account.display_name = "sendy"
      account.save
    end

    it "set attributes as part of save" do
      account = Sendy::Account.construct_from(id: nil,
                                              display_name: nil)

      stub_request(:post, "#{Sendy.app_host}/v1/accounts")
        .with(body: { display_name: "sendy", metadata: { key: "value" } })
        .to_return(body: JSON.generate("id" => "acct_123"))

      account.save(display_name: "sendy", metadata: { key: "value" })
    end
  end

  def transaction_fixture
    {
      "amount": 1,
      "campaign_id": nil,
      "created_at": "2018-07-31T16:02:14.108Z",
      "esp_id": 1,
      "eth_tx": nil,
      "from_address": nil,
      "id": 1,
      "subscriber_id": nil,
      "to_address": nil,
      "type": "EspToUserTxRecord",
      "updated_at": "2018-07-31T16:02:14.108Z",
      "user_id": 1
    }
  end

  def make_missing_id_error
    {
      error: {
        param: "id",
        type: "invalid_request_error",
        message: "Missing id",
      },
    }
  end
end
