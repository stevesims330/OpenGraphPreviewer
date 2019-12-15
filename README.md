# OpenGraphPreviewer
Allows users to preview Open Graph images for a given URL

# Installation

If you don't have Homebrew, run:

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

If you do, run:

`brew update`

After you update or install Homebrew, from the root `OpenGraphPreviewer/` directory:

1. `brew install rbenv`
1. Add `eval "$(rbenv init -)"` to the end of your `.bashrc` or `.zshrc`.
1. Restart your terminal to pick up the shell resource file changes, and `cd` to `OpenGraphPreviewer/`.
1. Install the right Ruby version with `rbenv install 2.6.5`.
1. Select a Ruby version with `rbenv global 2.6.5`.
1. Restart your terminal again and `cd` to `OpenGraphPreviewer/`.
1. Check that `gem env home` prints a local user Ruby, not the system Ruby.
1. `gem install bundler`
1. `brew install redis`
1. `bundle install`
1. `bin/webpack`

# Startup
In one tab:
`brew services start redis`
`bundle exec redis-server`

In a second tab:
`bundle exec sidekiq`

In a third tab:
`bundle exec rails s`

In a web browser:
Visit [http://localhost:3000](http://localhost:3000)

Tip: If you're developing, using command `bin/webpack --watch --colors --progress` in place of `bin/webpack` in its own tab will let you recompile as you code. This will speed up iterations.

# Future Scalability

Polling the backend is fine for a low user count. But if a lot of people were using the app, I'd want to use a library that lets the backend push events to the frontend when it finishes processing an OpenGraph page.

Caching the Open Graph image URL's would also improve scalability.

# Base Flow

1. User types or pastes in a URL.
1. Frontend sends URL to backend and waits for a response.
1. Backend kicks off a job to fetch that URL's Open Graph image and sends a request_id to the frontend.
1. Upon receiving the request_id, frontend begins polling the backend to see if that job has completed.
1. Once it has, frontend displays the Open Graph image if there is one. If not, it displays an error message with an explanation.

# Libraries

## gems

### http

I use the gem called [http](https://github.com/httprb/http) because it has a nice interface for following redirects. That way, https://ogp.me/, https://ogp.me/, https://www.ogp.me/, and https://www.ogp.me/  all return the same result.

### ogp

I searched Google for OpenGraph parsing gems and the two main results were [ogp](https://github.com/jcouture/ogp) and [opengraph](https://github.com/mobomo/opengraph).

I decided to use ogp because, unlike opengraph, it's still maintained. Also, [its tests](https://github.com/jcouture/ogp/blob/master/spec/ogp/open_graph_spec.rb) are more thorough and clear; I can't tell what functionality [opengraph is testing](https://github.com/mobomo/opengraph/blob/master/spec/opengraph_spec.rb) without carefully reading through the fixture files.

I also like how it decouples HTTP operations from parsing operations.

### react_on_rails

I picked [react_on_rails](https://github.com/shakacode/react_on_rails) over react-rails primarily because [unlike react-rails, react_on_rails doesn't depend on jQuery](https://sloboda-studio.com/blog/how-to-integrate-react-with-ruby-on-rails/). Avoiding unneeded dependencies is always good. Including webpack by default is also convenient.

### rspec-rails

Testing is very important and rspec is a pretty standard way of doing it in Ruby.

### sidekiq

For queuing, I chose [sidekiq](https://github.com/mperham/sidekiq) over [resque](https://github.com/resque/resque) because it's [much simpler to setup and use](https://github.com/mperham/sidekiq/wiki/Getting-Started).

## JavaScript

### yarn

I chose yarn over npm because I've found it to be more reliable.

### validator

The [validator](https://www.npmjs.com/package/validator) library lets me validate URL's clientside so that I can immediately tell users if they've mistyped one instead of them waiting for the backend to respond.

### react

I find React development to be rather straightforward due to the declarative nature of JSX. Having state management allows cleaner apps than managing the DOM directly.

### axios

I use [axios](https://github.com/axios/axios) for http requests since follows the [KISS principle](https://en.wikipedia.org/wiki/KISS_principle) pretty well. In particular, I like being able to handle successful requests in the `then()` separately from failed ones in `catch()` without having to worry about the exact status code, though axios allows that if necessary.
