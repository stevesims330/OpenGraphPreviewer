# Installation

If you don't have Homebrew, run:

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

```
brew install redis
bundle install
```

# Startup
In one tab:
`brew services start redis`
`bundle exec redis-server`

In a second tab:
`bundle exec sidekiq`

In a third tab:
`bundle exec rails s`

# OpenGraphPreviewer
Allows users to preview Open Graph images for a given URL

## gems

### ogp

I searched Google for OpenGraph parsing gems and the two main results were [ogp](https://github.com/jcouture/ogp) and [opengraph](https://github.com/mobomo/opengraph).

I decided to use ogp because, unlike opengraph, it's still maintained. Also, [its tests](https://github.com/jcouture/ogp/blob/master/spec/ogp/open_graph_spec.rb) are more thorough and clear; I can't tell what functionality [opengraph is testing](https://github.com/mobomo/opengraph/blob/master/spec/opengraph_spec.rb) without carefully reading through the fixture files.

I also like how it decouples HTTP operations from parsing operations.

### HTTP

I use the gem called [http](https://github.com/httprb/http) because it has a nice interface for following redirects. That way, https//ogp.me/, https://ogp.me/, https://www.ogp.me/, and https://www.ogp.me/ should all return the same result.

### Queueing

I chose [sidekiq](https://github.com/mperham/sidekiq) over [resque](https://github.com/resque/resque) because it's [much simpler to setup and use](https://github.com/mperham/sidekiq/wiki/Getting-Started).
