# frozen_string_literal: true

require 'spec_helper'

describe Sendy::User do
  before do
    Sendy.app_host = 'http://localhost:3000'
    Sendy.app_esp_name = 'sendy'
    Sendy.app_esp_password = '123456'

    stub_request(:get, "http://localhost:3000/esp_api/v1/users")
      .with(body: { "esp_name"=>"sendy", "esp_password"=>"123456" })
      .to_return(body: JSON.generate([user_fixture]))

    stub_request(:post, "http://localhost:3000/esp_api/v1/users")
      .with(body: { "esp_name"=>"sendy",
                    "esp_password"=>"123456",
                    "email" => "email@example.com" })
      .to_return(body: JSON.generate([user_fixture]))

    stub_request(:post, "http://localhost:3000/esp_api/v1/users/1")
      .with(body: { "esp_name"=>"sendy",
                    "esp_password"=>"123456",
                    "email" => "another@email.com" })
      .to_return(body: JSON.generate(user_fixture))

    stub_request(:put, "http://localhost:3000/esp_api/v1/users/1")
      .with(body: { "esp_name"=>"sendy",
                    "esp_password"=>"123456",
                    "email" => "another@email.com" })
      .to_return(body: JSON.generate(user_fixture))

    stub_request(:get, "http://localhost:3000/esp_api/v1/users/CXasPzXK3r3C52asgMv8vMk2")
      .with(body: { "esp_name"=>"sendy", "esp_password"=>"123456" })
      .to_return(body: JSON.generate(user_fixture))
  end

  it "is listable" do
    expect { Sendy::User.list }.to_not raise_error(NotImplementedError)
  end

  it "is findable" do
    user = Sendy::User.find("CXasPzXK3r3C52asgMv8vMk2")
    assert_requested :get, "#{Sendy.app_host}/esp_api/v1/users/#{user.api_token}"
    expect(user.is_a?(Sendy::User))
  end

  it "is retrievable" do
    user = Sendy::User.retrieve("CXasPzXK3r3C52asgMv8vMk2")
    assert_requested :get, "#{Sendy.app_host}/esp_api/v1/users/#{user.api_token}"
    expect(user.is_a?(Sendy::User))
  end

  it "is creatable" do
    user = Sendy::User.create(email: 'email@example.com')
    assert_requested :post, "#{Sendy.app_host}/esp_api/v1/users"
    expect(user.is_a?(Sendy::User))
  end

  it "is saveable" do
    user = Sendy::User.retrieve("CXasPzXK3r3C52asgMv8vMk2")
    user.email = 'another@email.com'
    user.save
    assert_requested :put, "#{Sendy.app_host}/esp_api/v1/users/1"
  end

  it "is updateable" do
    user = Sendy::User.update("1", email: "another@email.com")
    assert_requested :put, "#{Sendy.app_host}/esp_api/v1/users/1"
    expect(user.is_a?(Sendy::User))
  end

  it "is not deletable" do
    user = Sendy::User.retrieve("CXasPzXK3r3C52asgMv8vMk2")
    expect { user.delete }.to raise_error(NotImplementedError)
  end

  context "#campaigns" do
    before do
      stub_request(:get, "http://localhost:3000/api/v1/users/1/campaigns")
        .with(body: { "esp_name"=>"sendy", "esp_password"=>"123456" })
        .to_return(body: JSON.generate([campaign_fixture]))

      stub_request(:post, "http://localhost:3000/api/v1/users/1/campaigns")
        .with(body: { "esp_name"=>"sendy",
                      "esp_password"=>"123456",
                      "subject" => "Campaign Subject" })
        .to_return(body: JSON.generate(campaign_fixture))
    end

    it "can list campaigns" do
      user = Sendy::User.retrieve("CXasPzXK3r3C52asgMv8vMk2")
      campaigns = user.campaigns
      assert_requested :get, "#{Sendy.app_host}/api/v1/users/1/campaigns"
      expect(campaigns.data.is_a?(Array)).to be true
      expect(campaigns.first.is_a?(Sendy::Campaign)).to be true
    end

    it "can create campaigns" do
      user = Sendy::User.retrieve("CXasPzXK3r3C52asgMv8vMk2")
      campaign = user.campaigns.create(subject: 'Campaign Subject')
      assert_requested :post, "#{Sendy.app_host}/api/v1/users/1/campaigns"
      expect(campaign.user_id).to eql(user.id)
      expect(campaign.is_a?(Sendy::Campaign)).to be true
    end
  end

  context "#transactions" do
    before do
      stub_request(:get, "http://localhost:3000/api/v1/users/1/transactions")
        .with(body: { "esp_name"=>"sendy", "esp_password"=>"123456" })
        .to_return(body: JSON.generate([transaction_fixture]))
    end

    it "can list transactions" do
      user = Sendy::User.retrieve("CXasPzXK3r3C52asgMv8vMk2")
      transactions = user.transactions
      assert_requested :get, "#{Sendy.app_host}/api/v1/users/1/transactions"
      expect(transactions.data.is_a?(Array)).to be true
      expect(transactions.first.is_a?(Sendy::Transaction)).to be true
    end

    it "cannot create transactions" do
      user = Sendy::User.retrieve("CXasPzXK3r3C52asgMv8vMk2")
      expect do
        user.transactions.create(amount: 10)
      end.to raise_error(Sendy::InvalidRequestError)
      assert_not_requested :post, "#{Sendy.app_host}/api/v1/users/1/transactions"
    end
  end

  context "#events" do
    before do
      stub_request(:get, "http://localhost:3000/api/v1/users/1/events")
        .with(body: { "esp_name"=>"sendy", "esp_password"=>"123456" })
        .to_return(body: JSON.generate([event_fixture]))

      stub_request(:post, "http://localhost:3000/api/v1/users/1/events")
        .with(body: { "esp_name"=>"sendy", "esp_password"=>"123456",
                      "email"=>"email@example.com", "event" => "opened" })
        .to_return(body: JSON.generate(event_fixture))
    end

    it "can list events" do
      user = Sendy::User.retrieve("CXasPzXK3r3C52asgMv8vMk2")
      events = user.events
      assert_requested :get, "#{Sendy.app_host}/api/v1/users/1/events"
      expect(events.data.is_a?(Array)).to be true
      expect(events.first.is_a?(Sendy::Event)).to be true
    end

    it "can create events" do
      user = Sendy::User.retrieve("CXasPzXK3r3C52asgMv8vMk2")
      event = user.events.create(email: 'email@example.com', event: 'opened')
      assert_requested :post, "#{Sendy.app_host}/api/v1/users/1/events"
      expect(event.user_id).to eql(user.id)
      expect(event.is_a?(Sendy::Event)).to be true
    end
  end

  context "#subscribers" do
    before do
      stub_request(:get, "http://localhost:3000/api/v1/users/1/subscribers")
        .with(body: { "esp_name"=>"sendy", "esp_password"=>"123456" })
        .to_return(body: JSON.generate([subscriber_fixture]))
    end

    it "can list subscribers" do
      user = Sendy::User.retrieve("CXasPzXK3r3C52asgMv8vMk2")
      subscribers = user.subscribers
      assert_requested :get, "#{Sendy.app_host}/api/v1/users/1/subscribers"
      expect(subscribers.data.is_a?(Array)).to be true
      expect(subscribers.first.is_a?(Sendy::Subscriber)).to be true
    end

    it "cannot create subscribers" do
      user = Sendy::User.retrieve("CXasPzXK3r3C52asgMv8vMk2")
      expect do
        user.subscribers.create(email: 'email@example.com')
      end.to raise_error(Sendy::InvalidRequestError)
      assert_not_requested :post, "#{Sendy.app_host}/api/v1/users/1/subscribers"
    end
  end
end
