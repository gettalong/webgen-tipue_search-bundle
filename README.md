# Tipue Search integration for [webgen]

[Tipue Search] is a site search engine which uses jQuery. It provides
three modes of operation:

* live mode where one supplies a list of URLs which are then searched
  (not very fast, needs a web server),

* json mode where the search data is loaded via an Ajax request (still
  needs a web server) and

* static mode where the search data is loaded directly by the HTML file
  (fast, no web server needed).

[Tipue Search]: http://www.tipue.com/search/
[webgen]: http://webgen.gettalong.org


# Usage

## Provided Paths

This [webgen] extension bundle contains all needed Tipue Search files
except jQuery. Remember that one needs to load the jQuery library before
Tipue Search!

The Tipue Search files are provided as passive paths at the following
locations:

* `/javascriptss/tipue_search/tipuesearch.min.js` - the main Tipue
  Search javascript file

* `/javascripts/tipue_search/tipuesearch_set.js` - defines stop and
  replacement words as well as word stems

* `/stylesheets/tipue_search/tipuesearch.css` - the CSS file that includes the
  necessary styles

* `/stylesheets/tipue_search/img/loader.gif`,
  `/stylesheets/tipue_search/img/link.png`,
  `/stylesheets/tipue_search/img/search.gif,
  `/stylesheets/tipue_search/img/expand.png` - images needed by the CSS
  file

Additionally, the following paths are provided:

* `/templates/tipue_search.template` - provides the blocks for rendering
  the tag and the path handler contents


## Easy Usage

Tipue Search can easily be integrated into a webgen website by using the
included `tipue_search` tag:

    {tipue_search: {path: data.js, options: {mode: static},
                    entries: {alcn: /**/*.html}}}

The option `options` can be used to set any [Tipue Search
option][tipueset] and the option `nodes` specifies the nodes that should
appear in the search index (more information on this below).

If this tag occurs on a page, the needed nodes are automatically linked
to it and a new node representing the search index at the specified path
is created.

[tipueset]: http://www.tipue.com/search/docs/set/


## Manual Usage

It is also possible to craft the needed HTML fragments manually and just
use this extension for providing the necessary files. If you want to use
it this way, have a look at the [Tipue Search documentation][tipuedoc]

A search index node can be created by the path handler `tipue_search`
which uses paths in Webgen Page Format. Since no path extension is
registered for it, you need to explicitly specify the `handler` meta
information for a path that should be handled by the tipue_search
handler via a meta information path.

The following meta information on a tipue search node should be set:

* `entries` (mandatory): The node finder option set specifying the nodes
  that should be used for the search index. It is assumed that the nodes
  are valid HTML files.

* `mode` (mandatory): The Tipue Search mode (static, live or json).

* `content_css`: A CSS query for selecting the elements that contain the
  text that should be indexed. Default is `body`.

The template which defines the content of a search index node can be
customized by adding a content block named 'tipue_search' to the path.

[tipuedoc]: http://www.tipue.com/search/docs/



# Installation

The easiest way to install this extension bundle is by installing the
corresponding Rubygem:

    gem install webgen-tipue_search-bundle

If you don't use Rubygems, copy the folder
`lib/webgen/bundle/tipue_search` into your `ext` directory.

After that you just need to tell webgen to use this extension bundle by
adding the following line to your `ext/init.rb` file:

    load("tipue_search")


# Copyright and license

Copyright (c) 2013 Thomas Leitner under the MIT License (see LICENSE)

* * *

The included Tipue Search files are also licensed under the MIT (see
LICENSE-TIPUESEARCH).
