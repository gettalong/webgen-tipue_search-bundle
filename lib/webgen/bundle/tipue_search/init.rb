# Extension bundle initialization

mount_passive('data/', '/')

require_relative('tipue_search_tag')
require_relative('tipue_search_path_handler')

is_hash = lambda do |val|
  raise "The value has to be a hash" unless val.kind_of?(Hash)
  val
end

website.ext.tag.register('Webgen::Tag::TipueSearch', :mandatory => ['path', 'entries'])
option('tag.tipue_search.path', '')
option('tag.tipue_search.options', {'mode' => 'static'}, &is_hash)
option('tag.tipue_search.entries', nil, &is_hash)
option('tag.tipue_search.template', '/templates/tipue_search.template')

website.ext.path_handler.register('Webgen::PathHandler::TipueSearch')
