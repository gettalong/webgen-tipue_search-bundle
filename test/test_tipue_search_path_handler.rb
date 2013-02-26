# -*- encoding: utf-8 -*-

require 'webgen/test_helper'
require 'webgen/bundle/tipue_search/tipue_search_path_handler'
require 'webgen/content_processor'
require 'webgen/node_finder'
require 'webgen/path'

class TestPathHandlerTipueSearch < MiniTest::Unit::TestCase

  include Webgen::TestHelper

  class DummyDestination

    def initialize(data); @data = data; end
    def exists?(key); @data.has_key?(key); end
    def read(key); @data[key]; end

  end

  TIPUESEARCH_CONTENT = <<EOF
---
mode: static
entries: {alcn: /**/*.html}
EOF

  TIPUESEARCH_CONTENT_TEMPLATE = <<EOF
---
mode: static
entries: {alcn: /**/*.html}
--- name:tipue_search pipeline:erb
Yeah <%= context.node['title'] %>
EOF

  def setup
    setup_website('website.base_url' => 'http://example.com')
    @website.ext.node_finder = Webgen::NodeFinder.new(@website)
    @website.ext.destination = DummyDestination.new('/index.en.html' => '<body>testDATA</body>')

    @tipue_search = Webgen::PathHandler::TipueSearch.new(@website)

    root = Webgen::PathHandler::Base::Node.new(@website.tree.dummy_root, '/', '/')
    Webgen::PathHandler::Base::Node.new(root, 'index.html', '/index.en.html')
    Webgen::PathHandler::Base::Node.new(root, 'file.html', '/file.en.html')

    template_data = File.read(File.join(File.dirname(__FILE__), '..', 'lib', 'webgen', 'bundle', 'tipue_search',
                                        'data', 'templates', 'tipue_search.template'))
    RenderNode.new(template_data, @website.tree.root, 'sitemap.template', '/templates/tipue_search.template')

    @path = Webgen::Path.new('/test.search', 'dest_path' => '<parent><basename><ext>') { StringIO.new(TIPUESEARCH_CONTENT) }
    @path.meta_info.update(Webgen::Page.from_data(TIPUESEARCH_CONTENT).meta_info)
  end

  def test_create_node
    node = @tipue_search.create_nodes(@path, Webgen::Page.from_data(@path.data).blocks)

    refute_nil(node)
    assert_equal('/test.js', node.dest_path)
    assert_equal('/test.js', node.alcn)

    assert_raises(Webgen::NodeCreationError) do
      path = Webgen::Path.new('/test_feed_2') { StringIO.new("---\nmissing data: yes") }
      @tipue_search.create_nodes(path, 'unused')
    end
  end

  def test_content
    @website.ext.content_processor = Webgen::ContentProcessor.new
    @website.ext.content_processor.register('Ruby')

    @path['mode'] = 'static'
    content = @tipue_search.create_nodes(@path, Webgen::Page.from_data(@path.data).blocks).content
    assert_match(/var tipuesearch = {"pages": \[.*testDATA/, content)

    @website.tree.delete_node(@website.tree['/test.js'])
    @path['mode'] = 'json'
    content = @tipue_search.create_nodes(@path, Webgen::Page.from_data(@path.data).blocks).content
    assert_match(/var tipuesearch = {"pages": \[/, content)

    @website.tree.delete_node(@website.tree['/test.js'])
    @path['mode'] = 'live'
    content = @tipue_search.create_nodes(@path, Webgen::Page.from_data(@path.data).blocks).content
    assert_match(/var tipuesearch_pages = \[/, content)
  end

  def test_content_with_template
    @website.ext.content_processor = Webgen::ContentProcessor.new
    @website.ext.content_processor.register('Erb')

    path = Webgen::Path.new('/test.sitemap', 'dest_path' => '<parent><basename><ext>') { StringIO.new(TIPUESEARCH_CONTENT_TEMPLATE) }
    path.meta_info.update(Webgen::Page.from_data(TIPUESEARCH_CONTENT_TEMPLATE).meta_info)
    node = @tipue_search.create_nodes(path, Webgen::Page.from_data(path.data).blocks)

    assert_equal("Yeah Test\n", node.content)
  end

  def test_tipue_search_entries
    node = @tipue_search.create_nodes(@path, Webgen::Page.from_data(@path.data).blocks)
    assert_equal(%w[/index.html /file.html].map {|n| @website.tree[n]}, node.entries)
  end

end
