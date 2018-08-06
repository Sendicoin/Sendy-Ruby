# frozen_string_literal: true

require 'spec_helper'

describe Sendy::Subscriber do
  before do
    Sendy.app_host = 'http://localhost:3000'
    Sendy.app_esp_password = 'valid_api_token'

    stub_request(:get, "http://localhost:3000/v1/subscribers")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(data: [subscriber_fixture]))

    stub_request(:get, "http://localhost:3000/v1/subscribers/1")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(subscriber_fixture))
  end

  it "is listable" do
    subscribers = Sendy::Subscriber.list
    assert_requested :get, "#{Sendy.app_host}/v1/subscribers"
    expect(subscribers.data.is_a?(Array)).to be true
    expect(subscribers.first.is_a?(Sendy::Subscriber)).to be true
  end

  it "is retrievable" do
    subscriber = Sendy::Subscriber.retrieve("1")
    assert_requested :get, "#{Sendy.app_host}/v1/subscribers/1"
    expect(subscriber.is_a?(Sendy::Subscriber))
  end

  it "is not creatable" do
    expect { Sendy::Subscriber.create }.to raise_error(NotImplementedError)
    assert_not_requested :post, "#{Sendy.app_host}/v1/subscribers"
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
end
