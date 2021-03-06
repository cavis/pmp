# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/credential'

require 'webmock/minitest'

describe PMP::Credential do

  before do
    root_doc = json_file(:collection_root)
    stub_request(:get, 'https://api.pmp.io').to_return(:status => 200, :body => root_doc)
    @credential = PMP::Credential.new(user: "test", password: "password", endpoint: "https://api.pmp.io/")
  end

  it "has the user and password in the config" do
    @credential.user.must_equal 'test'
    @credential.password.must_equal 'password'
  end

  it "gets the base path for this subclass of API" do
    credential = PMP::Credential.new
    credential.credentials_url.must_equal "https://api.pmp.io/auth/credentials"
  end

  it "create a credential" do
    response_body = {
      client_id: "thisisnota-real-client-id-soverysorry",
      client_secret: "thisisnotarealsecreteither",
      token_expires_in: 1209600,
      scope: "write"
    }.to_json

    stub_request(:post, "https://publish.pmp.io/auth/credentials").
      with(:body => {"label"=>"what", "scope"=>"read", "token_expires_in"=>"2592000"},
           :headers => {'Accept'=>'*/*', 'Authorization'=>'Basic dGVzdDpwYXNzd29yZA==', 'Content-Type'=>'application/x-www-form-urlencoded'}).
      to_return(:status => 200, :body => response_body, :headers => {})

    new_creds = @credential.create(label: 'what')
    new_creds.client_id.must_equal "thisisnota-real-client-id-soverysorry"
  end

  it "list credentials" do

    response_body = {
      clients: [
        {
          client_id: "thisisnota-real-client-id-soverysorry1",
          client_secret: "thisisnotarealsecreteither1",
          label: "label 1",
          token_expires_in: 1209600,
          scope: "write"
        },
        {
          client_id: "thisisnota-real-client-id-soverysorry2",
          client_secret: "thisisnotarealsecreteither2",
          label: "label 2",
          token_expires_in: 1209600,
          scope: "read"
        }
      ]
    }.to_json

    stub_request(:get, "https://api.pmp.io/auth/credentials").
      with(:headers => {'Accept'=>'*/*', 'Authorization'=>'Basic dGVzdDpwYXNzd29yZA==', 'Content-Type'=>''}).
      to_return(:status => 200, :body => response_body, :headers => {})

    all_creds = @credential.list
  end

end
