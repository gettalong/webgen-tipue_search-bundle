# -*- encoding: utf-8 -*-

require 'tmpdir'
require 'fileutils'
require 'webgen/website'
require 'webgen/test_helper'

class TestTipueSearchIntegration < MiniTest::Unit::TestCase

  include Webgen::TestHelper

  def test_integration
    dir = Dir::Tmpname.create("test-webgen-website") {|n| n}
    Webgen::Website.new(dir).execute_task(:create_website)

    File.write(File.join(dir, 'webgen.config'), "# -*- ruby -*-\nload('tipue_search')")
    File.write(File.join(dir, 'src', 'index.page'), "{tipue_search: {path: test.data, entries: {alcn: /**/*.html}}}")
    ws = Webgen::Website.new(dir) do |ws|
      ws.config['website.base_url'] = 'file://'
    end
    ws.execute_task(:generate_website)

    assert(File.exists?(File.join(dir, 'out', 'test.js')))
    assert(File.exists?(File.join(dir, 'out', 'index.html')))
    assert_match(/tipuesearch/, File.read(File.join(dir, 'out', 'index.html')))
  ensure
    FileUtils.rm_rf(dir)
  end

end
