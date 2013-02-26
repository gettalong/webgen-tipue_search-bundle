# -*- encoding: utf-8 -*-

require 'json'
require 'nokogiri'
require 'webgen/path_handler/base'
require 'webgen/path_handler/page_utils'
require 'webgen/context'

module Webgen
  class PathHandler

    # Path handler for creating a Tipue Search site index.
    class TipueSearch

      include Base
      include PageUtils


      # Provides custom methods for tipue search nodes.
      class Node < PageUtils::Node

        # Return the entries for the tipue search +node+.
        def entries
          tree.website.ext.node_finder.find(node_info[:entries], self)
        end

        # Return the text content of the given node.
        def text_for(node)
          if tree.website.ext.destination.exists?(node.dest_path)
            Nokogiri::HTML(tree.website.ext.destination.read(node.dest_path)).
              css(self['content_css'] || 'body').text.gsub(/\s+/, ' ')
          else
            ''
          end
        end

      end


      # The mandatory keys that need to be set in a tipue search file.
      MANDATORY_INFOS = %W[mode entries]

      # Create a Tipue Search site index from +path+.
      def create_nodes(path, blocks)
        if MANDATORY_INFOS.any? {|t| path.meta_info[t].nil?}
          raise Webgen::NodeCreationError.new("At least one of #{MANDATORY_INFOS.join('/')} is missing",
                                              "path_handler.tipue_search", path)
        end

        if @website.config['website.base_url'].empty?
          raise Webgen::NodeCreationError.new("The configuration option 'website.base_url' needs to be set",
                                              "path_handler.tipue_search", path)
        end

        path.ext = 'js'
        path['node_class'] = Node.to_s
        path['write_order'] = 'z'
        create_node(path) do |node|
          set_blocks(node, blocks)
          node.node_info[:entries] = {:flatten => true, :and => node['entries']}
          @website.ext.item_tracker.add(node, :nodes, :node_finder_option_set,
                                        {:opts => node.node_info[:entries], :ref_alcn => node.alcn}, :content)
        end
      end

      # Return the rendered feed represented by +node+.
      def content(node)
        context = Webgen::Context.new(@website)
        context.render_block(:name => "tipue_search", :node => 'first',
                             :chain => [node, node.resolve("/templates/tipue_search.template", node.lang, true),
                                        node].compact)
      end

    end

  end
end
