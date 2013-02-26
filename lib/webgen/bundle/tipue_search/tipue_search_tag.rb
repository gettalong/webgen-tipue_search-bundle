# -*- encoding: utf-8 -*-

require 'json'
require 'webgen/tag'

module Webgen
  class Tag

    # Generates the Tipue Search HTML fragments (input box, result area) and links the necessary
    # nodes to the destination node.
    module TipueSearch

      # Generate the menu.
      def self.call(tag, body, context)
        path = Webgen::Path.append(context.ref_node.parent.alcn, context[:config]['tag.tipue_search.path'])
        path = Webgen::Path.new(path)

        path.meta_info['mode'] = context[:config]['tag.tipue_search.options']['mode'] || 'static'
        path.meta_info['content_css'] = context[:config]['tag.tipue_search.options']['liveDescription'] || 'body'
        path.meta_info['entries'] = context[:config]['tag.tipue_search.entries']
        path.meta_info['handler'] = 'tipue_search'

        node = context.website.ext.path_handler.create_secondary_nodes(path, '', context.ref_node.alcn).first

        context.html_head.link_file(:css, '/stylesheets/tipue_search/tipuesearch.css')
        context.html_head.link_file(:js, '/javascripts/tipue_search/tipuesearch_set.js')
        context.html_head.link_file(:js, node.alcn) unless path.meta_info['mode'] == 'json'
        context.html_head.link_file(:js, '/javascripts/tipue_search/tipuesearch.min.js')

        context[:data_node] = node
        Webgen::Tag.render_tag_template(context, "tipue_search")
      end

    end

  end
end
