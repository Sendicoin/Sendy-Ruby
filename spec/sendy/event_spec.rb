# frozen_string_literal: true

require 'spec_helper'

describe Sendy::Event do
  before do
    Sendy.app_host = 'http://localhost:3000'
    Sendy.app_esp_password = 'valid_api_token'

    stub_request(:get, "http://localhost:3000/v1/events")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(data: [event_fixture]))

    stub_request(:get, "http://localhost:3000/v1/events/1")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(event_fixture))

    stub_request(:post, "http://localhost:3000/v1/events")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(event_fixture))
  end

  it "is listable" do
    events = Sendy::Event.list
    assert_requested :get, "#{Sendy.app_host}/v1/events"
    expect(events.data.is_a?(Array)).to be true
    expect(events.first.is_a?(Sendy::Event)).to be true
  end

  it "is retrievable" do
    event = Sendy::Event.retrieve("1")
    assert_requested :get, "#{Sendy.app_host}/v1/events/1"
    expect(event.is_a?(Sendy::Event))
  end

  it "is creatable" do
    event = Sendy::Event.create
    assert_requested :post, "#{Sendy.app_host}/v1/events"
    expect(event.is_a?(Sendy::Event))
  end

  it "is not saveable" do
    event = Sendy::Event.retrieve("1")
    event.event = "other_event_type"
    expect { event.save }.to raise_error(NotImplementedError)
    assert_not_requested :post, "#{Sendy.app_host}/v1/events/#{event.id}"
  end

  it "is not updateable" do
    expect do
      Sendy::Event.update("1", event: "other")
    end.to raise_error(NotImplementedError)
  end

  it "is not deletable" do
    event = Sendy::Event.retrieve("1")
    expect { event.delete }.to raise_error(NotImplementedError)
  end
end
