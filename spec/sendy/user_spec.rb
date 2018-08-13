# frozen_string_literal: true

require 'spec_helper'

describe Sendy::User do
  before do
    Sendy.app_host = 'http://localhost:3000'
    Sendy.app_esp_password = 'valid_api_token'

    stub_request(:get, "http://localhost:3000/v1/users")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(data: [user_fixture]))

    stub_request(:post, "http://localhost:3000/v1/users")
      .with(
        body: { 'email' => 'email@example.com' },
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(data: [user_fixture]))

    stub_request(:post, "http://localhost:3000/v1/users/1")
      .with(
        body: {"email"=>"another@email.com"},
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(user_fixture))

    stub_request(:get, "http://localhost:3000/v1/users/1")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(user_fixture))
  end

  # TODO by ESP only
  it "is not listable" do
    expect { Sendy::User.list }.to raise_error(NotImplementedError)
  end

  it "is retrievable" do
    user = Sendy::User.retrieve("1")
    assert_requested :get, "#{Sendy.app_host}/v1/users/1"
    expect(user.is_a?(Sendy::User))
  end

  it "is creatable" do
    user = Sendy::User.create(email: 'email@example.com')
    assert_requested :post, "#{Sendy.app_host}/v1/users"
    expect(user.is_a?(Sendy::User))
  end

  it "is saveable" do
    user = Sendy::User.retrieve("1")
    user.email = 'another@email.com'
    user.save
    assert_requested :post, "#{Sendy.app_host}/v1/users/#{user.id}"
  end

  it "is updateable" do
    user = Sendy::User.update("1", email: "another@email.com")
    assert_requested :post, "#{Sendy.app_host}/v1/users/1"
    expect(user.is_a?(Sendy::User))
  end

  it "is not deletable" do
    user = Sendy::User.retrieve("1")
    expect { user.delete }.to raise_error(NotImplementedError)
  end

  context "#campaigns" do
    before do
      stub_request(:get, "http://localhost:3000/v1/users/1/campaigns")
        .with(
          headers: {
            'Authorization'=>'token valid_api_token',
          })
            .to_return(body: JSON.generate(data: [campaign_fixture]))

      stub_request(:post, "http://localhost:3000/v1/users/1/campaigns")
        .with(
          body: {"subject"=>"Campaign Subject"},
          headers: {
            'Authorization'=>'token valid_api_token',
          })
            .to_return(body: JSON.generate(campaign_fixture))
    end

    it "can list campaigns" do
      user = Sendy::User.retrieve("1")
      campaigns = user.campaigns
      assert_requested :get, "#{Sendy.app_host}/v1/users/1/campaigns"
      expect(campaigns.data.is_a?(Array)).to be true
      expect(campaigns.first.is_a?(Sendy::Campaign)).to be true
    end

    it "can create campaigns" do
      user = Sendy::User.retrieve("1")
      campaign = user.campaigns.create(subject: 'Campaign Subject')
      assert_requested :post, "#{Sendy.app_host}/v1/users/1/campaigns"
      expect(campaign.user_id).to eql(user.id)
      expect(campaign.is_a?(Sendy::Campaign)).to be true
    end
  end

  context "#transactions" do
    before do
      stub_request(:get, "http://localhost:3000/v1/users/1/transactions")
        .with(
          headers: {
            'Authorization'=>'token valid_api_token',
          })
        .to_return(body: JSON.generate(data: [transaction_fixture]))

    end

    it "can list transactions" do
      user = Sendy::User.retrieve("1")
      transactions = user.transactions
      assert_requested :get, "#{Sendy.app_host}/v1/users/1/transactions"
      expect(transactions.data.is_a?(Array)).to be true
      expect(transactions.first.is_a?(Sendy::Transaction)).to be true
    end

    it "cannot create transactions" do
      user = Sendy::User.retrieve("1")
      expect do
        user.transactions.create(amount: 10)
      end.to raise_error(Sendy::InvalidRequestError)
      assert_not_requested :post, "#{Sendy.app_host}/v1/users/1/transactions"
    end
  end

  context "#events" do
    before do
      stub_request(:get, "http://localhost:3000/v1/users/1/events")
        .with(
          headers: {
            'Authorization'=>'token valid_api_token',
          })
        .to_return(body: JSON.generate(data: [event_fixture]))

      stub_request(:post, "http://localhost:3000/v1/users/1/events")
        .with(
          body: {"email"=>"email@example.com", "event" => "opened"},
          headers: {
            'Authorization'=>'token valid_api_token',
          })
            .to_return(body: JSON.generate(event_fixture))
    end

    it "can list events" do
      user = Sendy::User.retrieve("1")
      events = user.events
      assert_requested :get, "#{Sendy.app_host}/v1/users/1/events"
      expect(events.data.is_a?(Array)).to be true
      expect(events.first.is_a?(Sendy::Event)).to be true
    end

    it "can create events" do
      user = Sendy::User.retrieve("1")
      event = user.events.create(email: 'email@example.com', event: 'opened')
      assert_requested :post, "#{Sendy.app_host}/v1/users/1/events"
      expect(event.user_id).to eql(user.id)
      expect(event.is_a?(Sendy::Event)).to be true
    end
  end

  context "#subscribers" do
    before do
      stub_request(:get, "http://localhost:3000/v1/users/1/subscribers")
        .with(
          headers: {
            'Authorization'=>'token valid_api_token',
          })
            .to_return(body: JSON.generate(data: [subscriber_fixture]))
    end

    it "can list subscribers" do
      user = Sendy::User.retrieve("1")
      subscribers = user.subscribers
      assert_requested :get, "#{Sendy.app_host}/v1/users/1/subscribers"
      expect(subscribers.data.is_a?(Array)).to be true
      expect(subscribers.first.is_a?(Sendy::Subscriber)).to be true
    end

    it "cannot create subscribers" do
      user = Sendy::User.retrieve("1")
      expect do
        user.subscribers.create(email: 'email@example.com')
      end.to raise_error(Sendy::InvalidRequestError)
      assert_not_requested :post, "#{Sendy.app_host}/v1/users/1/subscribers"
    end
  end
end
