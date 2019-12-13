# OpenGraphPreviewer
Allows users to preview Open Graph images for a given URL

## gems

### Parsing

I searched Google for OpenGraph parsing gems and the two main results were [ogp](https://github.com/jcouture/ogp) and [opengraph](https://github.com/mobomo/opengraph).

I decided to use ogp because, unlike opengraph, it's still maintained. Also, [its tests](https://github.com/jcouture/ogp/blob/master/spec/ogp/open_graph_spec.rb) are more thorough and clear; I can't tell what functionality [opengraph is testing](https://github.com/mobomo/opengraph/blob/master/spec/opengraph_spec.rb) without carefully reading through the fixture files.

I also like how it decouples HTTP operations from parsing operations.
