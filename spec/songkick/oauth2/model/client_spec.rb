require 'spec_helper'

describe Songkick::OAuth2::Model::Client do
  before do
    @client = Songkick::OAuth2::Model::Client.create(:name => 'App', :redirect_uri => 'http://example.com/cb')
    @owner  = Factory(:owner)
    Songkick::OAuth2::Model::Authorization.for(@owner, @client)
  end

  it "is valid" do
    expect(@client).to be_valid
  end

  it "is invalid without a name" do
    @client.name = nil
    expect(@client).not_to be_valid
  end

  it "is invalid without a redirect_uri" do
    @client.redirect_uri = nil
    expect(@client).not_to be_valid
  end

  it "is invalid with a non-URI redirect_uri" do
    @client.redirect_uri = 'foo'
    expect(@client).not_to be_valid
  end

  # http://en.wikipedia.org/wiki/HTTP_response_splitting
  it "is invalid if the URI contains HTTP line breaks" do
    @client.redirect_uri = "http://example.com/c\r\nb"
    expect(@client).not_to be_valid
  end

  if (defined?(ActiveRecord::VERSION) && ActiveRecord::VERSION::MAJOR <= 3) || defined?(ProtectedAttributes)
    it "cannot mass-assign client_id" do
      @client.update_attributes(:client_id => 'foo')
      expect(@client.client_id).not_to eql('foo')
    end

    it "cannot mass-assign client_secret" do
      @client.update_attributes(:client_secret => 'foo')
      expect(@client.client_secret).not_to eql('foo')
    end
  end

  it "has client_id and client_secret filled in" do
    expect(@client.client_id).not_to be_nil
    expect(@client.client_secret).not_to be_nil
  end

  it "destroys its authorizations on destroy" do
    @client.destroy
    expect(Songkick::OAuth2::Model::Authorization.count).to be_zero
  end
end

