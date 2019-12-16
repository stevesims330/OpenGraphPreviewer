# OpenGraphPreviewer
Allows users to preview Open Graph images for a given URL.

# Installation

Install Homebrew if necessary:

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

Then, from the root `OpenGraphPreviewer/` directory:

1. `brew install rbenv`
1. `brew install redis`
1. `brew install yarn`
1. Add `eval "$(rbenv init -)"` to the end of `.bashrc` or `.zshrc`.
1. Restart the terminal to pick up the shell resource file changes, and `cd` to `OpenGraphPreviewer/`.
1. Install the right Ruby version with `rbenv install 2.6.5`.
1. Select a Ruby version with `rbenv global 2.6.5`.
1. Restart the terminal again and `cd` to `OpenGraphPreviewer/`.
1. Check that `gem env home` prints a local user Ruby, not the system Ruby. If _rvm_ is installed, many errors may be printed. Ignore them and look for the Ruby filepath at the very bottom of the printout.
1. `gem install bundler`
1. `bundle install`
1. `yarn`
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

# Design Decisions

## Scalability

To avoid making multiple requests for the same website, results aren't refetched if an Open Graph image URL already exists for that website.

Polling the backend is fine for a low user count. But if a lot of people were using the app, a library that lets the backend push events to the frontend when it finishes processing an OpenGraph page would be more scalable.

## Datastore

Redis as a datastore is much faster than storing the results of each request in a database. Redis scales better, especially considering that data is polled from the frontend. Many users making simultaneous requests on the database would result in performance issues.

An alternative would have been an in-memory database, however, the data is simple enough that having one would add unneeded complexity.

## HttpService and ImageParsingService

Wrapping these gems into services allows the gems to easily be replaced without changing every single usage. They raise custom exceptions for the same reason.

# Base Flow

1. User types or pastes in a website URL.
1. Frontend sends the website URL to the backend and waits for a response.
1. The backend kicks off a job and returns a 200.
1. Upon receiving a 200, the frontend begins polling the backend to see if a result exists for the provided website URL.
1. While this is happening, the job checks if the website URL has already been cached in Redis from an earlier request _and_ if the cached result has an Open Graph image URL. If so, it returns the Open Graph URL without trying to fetch it. Otherwise, it fetches the website's Open Graph image URL. It caches the result with the website URL as the key; the result contains either the Open Graph URL or an error message.
1. Once a result for the website URL is cached in Redis, the frontend displays the URL's Open Graph image if there is one. If not, it displays an error message with an explanation.

# Libraries

## gems

### http

[http](https://github.com/httprb/http) automatically follows redirects. That way, https://ogp.me/, https://ogp.me/, https://www.ogp.me/, and https://www.ogp.me/ all return the same result.

### ogp

[ogp](https://github.com/jcouture/ogp) is still maintained, unlike the alternative [opengraph](https://github.com/mobomo/opengraph).

### react_on_rails

[react_on_rails](https://github.com/shakacode/react_on_rails) does not depend on jQuery, [unlike the alternative react-rails](https://sloboda-studio.com/blog/how-to-integrate-react-with-ruby-on-rails/).

### rspec-rails

Testing is very important and [rspec](https://rspec.info/) is a pretty standard way of doing it in Ruby.

### sidekiq

[sidekiq](https://github.com/mperham/sidekiq) is [much simpler to setup and use](https://github.com/mperham/sidekiq/wiki/Getting-Started) compared to the alternative [resque](https://github.com/resque/resque). This is important with little control over the systems OpenGraphPreviewer is being installed on.

## JavaScript

### validator

The [validator](https://www.npmjs.com/package/validator) library allows for clientside URL validation so users immediately know if they've mistyped a URL.

### react

[React](https://reactjs.org/) development is rather straightforward due to the declarative nature of JSX. Having state management allows clean apps compared to managing the DOM directly.

### axios

[axios](https://github.com/axios/axios) for http requests since it has a simple API.
