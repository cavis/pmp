# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/collection_document'

require 'webmock/minitest'

describe PMP::CollectionDocument do

  it "can create a new, blank collection doc" do
    doc = PMP::CollectionDocument.new
  end

  it "canget options from configuration" do
    doc = PMP::CollectionDocument.new
    doc.options.wont_be_nil
    doc.options[:adapter].must_equal :excon
  end

  it "should default href to endpoint" do
    doc = PMP::CollectionDocument.new
    doc.href.must_equal "https://api.pmp.io/"
  end

  it "can create from remote result" do
    response = mashify({
      version: '1.0'
    })

    doc = PMP::CollectionDocument.new(document: response)
    doc.version.must_equal '1.0'
  end

  it "should assign attributes" do
    doc = PMP::CollectionDocument.new(document: json_fixture(:collection_basic))
    doc.guid.must_equal "f84e9018-5c21-4b32-93f8-d519308620f0"
    doc.valid.from.must_equal "2013-05-10T15:17:00.598Z"
  end

  it "should set-up links" do
    doc = PMP::CollectionDocument.new(document: json_fixture(:collection_basic))
    doc.profile.must_be_instance_of PMP::Link
    doc.profile.href.must_equal "http://api-sandbox.pmp.io/profiles/story"
    doc.self.href.must_equal "http://api-sandbox.pmp.io/docs/f84e9018-5c21-4b32-93f8-d519308620f0"
    doc.collection.href.must_equal "http://api-sandbox.pmp.io/docs/"
  end

  it "should load" do
    stub_request(:get, "https://api.pmp.io/").
      with(:headers => {'Accept'=>'application/vnd.pmp.collection.doc+json', 'Content-Type'=>'application/vnd.pmp.collection.doc+json', 'Host'=>'api.pmp.io:443', 'User-Agent'=>'PMP-SDK Ruby Gem 0.0.1'}).
      to_return(:status => 200, :body => "", :headers => {})

    doc = PMP::CollectionDocument.new
    doc.load
  end

end
