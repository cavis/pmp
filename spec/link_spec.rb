# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'pmp/link'

require 'webmock/minitest'

describe PMP::Link do

  before(:each) {
    @parent = PMP::CollectionDocument.new(oauth_token:'thisisnotarealtoken')
    @info = {'href' => 'http://api-sandbox.pmp.io/docs/'}
    @link = PMP::Link.new(@info, @parent)
  }

  it "can create a new link" do
    @link.wont_be_nil
  end

  it "has a parent" do
    @link = PMP::Link.new
    @link.parent.wont_be_nil
    parent = PMP::CollectionDocument.new
    @link = PMP::Link.new(@info, parent)
    @link.parent.must_equal(parent)
  end

  it "can save params to attributes" do
    @link.href.must_equal 'http://api-sandbox.pmp.io/docs/'
  end

  it "can retrieve link resource" do
    @link.href.must_equal 'http://api-sandbox.pmp.io/docs/'
  end

  it "can become json" do
    @link.as_json.must_equal @info
  end

  it "gets a url based on an href string" do
    @link.href.must_equal 'http://api-sandbox.pmp.io/docs/'
    @link.href_template.must_be_nil
    @link.params.must_equal({})

    url = @link.url
    url.must_equal 'http://api-sandbox.pmp.io/docs/'
  end

  it "can get a link for templated href" do
    @link = PMP::Link.new(query_document_info, @parent)
    @link.hints.must_equal query_document_info['hints']
    @link.url.must_equal "https://api-sandbox.pmp.io/docs"
    @link.where('limit' => 10).url.must_equal "https://api-sandbox.pmp.io/docs?limit=10"
    @link.url.must_equal "https://api-sandbox.pmp.io/docs"
  end

  it "follows a link to get underlying resource" do

    link_doc = json_file(:collection_query)

    stub_request(:get, "https://api-sandbox.pmp.io/docs?limit=10&tag=test").
      with(:headers => {'Accept'=>'application/vnd.collection.doc+json', 'Content-Type'=>'application/vnd.collection.doc+json', 'Host'=>'api-sandbox.pmp.io:443'}).
      to_return(:status => 200, :body => link_doc, :headers => {})

    @link = PMP::Link.new(query_document_info, @parent)
    docs = @link.where(limit: 10, tag: 'test')
    docs.must_be_instance_of PMP::Link
    guids = docs.items.collect(&:guid).sort
    guids.first.must_equal "0390510e-f1cb-4cef-b362-1e916d4c92f1"
    guids.last.must_equal "f237f87d-1f40-4178-9eba-b068b5dc6f7b"
  end

  def query_document_info
    {
        "hints" => {
            "allow" => [
                "GET"
            ]
        },
        "href-template" => "https://api-sandbox.pmp.io/docs{?limit,offset,tag,collection,text,searchsort,has,author,distributor,distributorgroup,startdate,enddate,profile,language}",
        "href-vars" => {
            "author" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
            "collection" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
            "distributor" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
            "distributorgroup" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
            "enddate" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
            "has" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
            "language" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
            "limit" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
            "offset" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
            "profile" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
            "searchsort" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
            "startdate" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
            "tag" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval",
            "text" => "https://github.com/publicmediaplatform/pmpdocs/wiki/Content-Retrieval"
        },
        "rels" => [
            "urn:collectiondoc:query:docs"
        ],
        "title" => "Query for documents"
    }
  end

end
