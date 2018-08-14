# frozen_string_literal: true

require 'spec_helper'

describe Sendy::Subscriber do
  before do
    Sendy.app_host = 'http://localhost:3000'
    Sendy.app_esp_password = 'valid_api_token'

    stub_request(:get, "http://localhost:3000/api/v1/subscribers")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(data: [subscriber_fixture]))

    stub_request(:get, "http://localhost:3000/api/v1/subscribers/1")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(subscriber_fixture))
  end

  it "is listable" do
    subscribers = Sendy::Subscriber.list
    assert_requested :get, "#{Sendy.app_host}/api/v1/subscribers"
    expect(subscribers.data.is_a?(Array)).to be true
    expect(subscribers.first.is_a?(Sendy::Subscriber)).to be true
  end

  it "is retrievable" do
    subscriber = Sendy::Subscriber.retrieve("1")
    assert_requested :get, "#{Sendy.app_host}/api/v1/subscribers/1"
    expect(subscriber.is_a?(Sendy::Subscriber))
  end

  it "is not creatable" do
    expect { Sendy::Subscriber.create }.to raise_error(NotImplementedError)
    assert_not_requested :post, "#{Sendy.app_host}/api/v1/subscribers"
  end

  it "is not saveable" do
    subscriber = Sendy::Subscriber.retrieve("1")
    subscriber.event = "other_event_type"
    expect { subscriber.save }.to raise_error(NotImplementedError)
  end

  it "is not updateable" do
    expect do
      Sendy::Subscriber.update("1", email: "other")
    end.to raise_error(NotImplementedError)
  end

  it "is not deletable" do
    subscriber = Sendy::Subscriber.retrieve("1")
    expect { subscriber.delete }.to raise_error(NotImplementedError)
  end

  context "#events" do
    before do
      stub_request(:get, "http://localhost:3000/api/v1/subscribers/1/events")
        .with(
          headers: {
            'Authorization'=>'token valid_api_token',
          })
        .to_return(body: JSON.generate(data: [event_fixture]))

      stub_request(:post, "http://localhost:3000/api/v1/subscribers/1/events")
        .with(
          body: {"email"=>"email@example.com", "event" => "opened"},
          headers: {
            'Authorization'=>'token valid_api_token',
          })
            .to_return(body: JSON.generate(event_fixture))
    end

    it "can list events" do
      subscriber = Sendy::Subscriber.retrieve("1")
      events = subscriber.events
      assert_requested :get, "#{Sendy.app_host}/api/v1/subscribers/1/events"
      expect(events.data.is_a?(Array)).to be true
      expect(events.first.is_a?(Sendy::Event)).to be true
    end

    it "can create events" do
      subscriber = Sendy::Subscriber.retrieve("1")
      event = subscriber.events.create(email: 'email@example.com', event: 'opened')
      assert_requested :post, "#{Sendy.app_host}/api/v1/subscribers/1/events"
      expect(event.subscriber_id).to eql(subscriber.id)
      expect(event.is_a?(Sendy::Event)).to be true
    end
  end

  context "#campaigns" do
    before do
      stub_request(:get, "http://localhost:3000/api/v1/subscribers/1/campaigns")
        .with(
          headers: {
            'authorization'=>'token valid_api_token',
          })
            .to_return(body: JSON.generate(data: [campaign_fixture]))

      stub_request(:post, "http://localhost:3000/api/v1/subscribers/1/campaigns")
        .with(
          body: {"subject"=>"campaign subject"},
          headers: {
            'authorization'=>'token valid_api_token',
          })
            .to_return(body: JSON.generate(campaign_fixture))
    end

    it "can list campaigns" do
      subscriber = Sendy::Subscriber.retrieve("1")
      campaigns = subscriber.campaigns
      assert_requested :get, "#{Sendy.app_host}/api/v1/subscribers/1/campaigns"
      expect(campaigns.data.is_a?(Array)).to be true
      expect(campaigns.first.is_a?(Sendy::Campaign)).to be true
    end

    it "can create campaigns" do
      subscriber = Sendy::Subscriber.retrieve("1")
      campaign = subscriber.campaigns.create(subject: 'campaign subject')
      assert_requested :post, "#{Sendy.app_host}/api/v1/subscribers/1/campaigns"
      expect(campaign.is_a?(Sendy::Campaign)).to be true
    end
  end
end
