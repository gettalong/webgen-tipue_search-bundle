# -*- encoding: utf-8 -*-

require 'webgen/test_helper'
require 'webgen/bundle/tipue_search/tipue_search_tag'
require 'webgen/path'
require 'webgen/content_processor'

class TestTagTipueSearch < MiniTest::Unit::TestCase

  include Webgen::TestHelper

  class Nirvana
    def method_missing(*args, &block)
      self
    end
  end

  class DummyPathHandler

    def set_result(node)
      @node = node
    end

    def create_secondary_nodes(path, body, source_alcn)
      @path, @body, @source_alcn = path, body, source_alcn
      [@node]
    end

    def verify
      yield(@path, @body, @source_alcn)
    end

  end

  def test_call
    setup_context
    def (@context).html_head(); Nirvana.new; end

    @website.config['website.base_url'] = 'test://'
    @website.ext.path_handler = DummyPathHandler.new
    @website.ext.content_processor = Webgen::ContentProcessor.new
    @website.ext.content_processor.register('Erb')

    root = Webgen::Node.new(@website.tree.dummy_root, '/', '/')
    node = Webgen::PathHandler::Base::Node.new(root, 'file.page', '/file.html')
    template_data = File.read(File.join(File.dirname(__FILE__), '..', 'lib', 'webgen', 'bundle', 'tipue_search',
                                        'data', 'templates', 'tipue_search.template'))
    RenderNode.new(template_data, root, 'template', '/template')

    @website.ext.path_handler.set_result(Webgen::PathHandler::Base::Node.new(root, 'test.data', '/test.data'))
    @context[:chain] = [node]

    assert_tag_result(/"mode":"static"/, 'test.data', {'mode' => 'static', 'liveDescription' => '*'},
                      {'alcn' => '/**/*.html'})
    assert_tag_result(/"mode":"live"/, 'test.data', {'mode' => 'live'}, {'alcn' => '/**/*.html'})
    assert_tag_result(/"mode":"json".*"contentLocation"/, 'test.data', {'mode' => 'json'}, {'alcn' => '/**/*.html'})
  end

  def assert_tag_result(result, path, options, entries)
    @context[:config] = {'tag.tipue_search.path' => path,
      'tag.tipue_search.options' => options,
      'tag.tipue_search.entries' => entries,
      'tag.tipue_search.template' => '/template'}

    assert_match(result, Webgen::Tag::TipueSearch.call('tipue_search', '', @context))

    @website.ext.path_handler.verify do |s_path, s_body, s_alcn|
      assert_equal("/#{path}", s_path.path)
      assert_equal(options['mode'], s_path['mode'])
      assert_equal(options['liveDescription'] || 'body', s_path['content_css'])
      assert_equal(entries, s_path['entries'])
    end
  end

end
