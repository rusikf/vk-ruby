#VK-RUBY
[![Build Status](https://secure.travis-ci.org/zinenko/vk-ruby.png)](http://travis-ci.org/zinenko/vk-ruby)

Ruby wrapper for vk.com API.

__VK-RUBY__ gives you full access to all features api.
Has several types of method naming and methods calling, optional authorization, files uploading, logging, irb integration, parallel method calling and any faraday-supported http adapter of your choice.

Compatible with Ruby 1.9.2, 1.9.3, Jruby and RBX.

What do I need to start working with vk.com API?
First of all, to [register](http://vk.com/editapp?act=create) their own application and obtain the keys;
And read [vk api documentation](http://vk.com/developers.php).

[vk-ruby documentation](http://rubydoc.info/github/zinenko/vk-ruby/master/frames)

## Installation

```.bash

gem install vk-ruby
```

## How to use

### API method calling

```.ruby

app = VK::Application.new access_token: TOKEN

app.friends.getOnline uid: 1 # => Online friends

# similar call

app.friends.get_online uid: 1

app.vk_call 'friends.getOnline', {uid: 1}

```

### Parallel method call

```.ruby

app = VK::Application.new access_token: TOKEN

app.adapter = :em_http # :em_synchrony or :patron or :typhoeus

results = []

app.in_parallel do
  10.times do |i|
    results << app.friends.get_online uid: i
  end
end

result.size # => 10

```

### Upload files

Uploading files to vk servers performed in 3 steps:

1. Getting url to download the file.
2. File download.
3. Save the file.

The first and third steps are produced by calls to certain API methods as described above.
Details downloading files, see the [relevant section of the documentation](http://vk.com/developers.php?oid=-1&p=%D0%9F%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81_%D0%B7%D0%B0%D0%B3%D1%80%D1%83%D0%B7%D0%BA%D0%B8_%D1%84%D0%B0%D0%B9%D0%BB%D0%BE%D0%B2_%D0%BD%D0%B0_%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80_%D0%92%D0%9A%D0%BE%D0%BD%D1%82%D0%B0%D0%BA%D1%82%D0%B5).

When you call the upload also need to specify the mime type file.

```.ruby

url = 'http://cs2222.vkontakte.ru/upload.php?act=do_add'

app.upload(url: url, photo: ['/path/to/example.jpg', 'image/jpeg'])
```

### Authorization

[VK](vk.com) has several types of applications and several types of authorization. They are different ways of authorization and access rights.
more details refer to the [documentation](http://vk.com/developers.php?oid=-1&p=%D0%90%D0%B2%D1%82%D0%BE%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F)

#### Application

```.ruby

app = VK::Application.new app_id: 222, app_secret: 'secret key'

app.authorize(type: :serverside, code: CODE) # => {"access_token":"533bacf01e11f55b536a565b57531ac114461ae8736d6506a3", "expires_in":43200, "user_id":6492}

# if app is secure application server

app.authorize(type: :secure) # => {"access_token":"533bacf01e11f55b536a565b57531ac114461ae8736d6506a3"}

```

#### Serverside(deprecated)

```.ruby

app = VK::Serverside.new app_id: 222, app_secret: 'secret key'

app.authorize(CODE) # => {"access_token":"533bacf01e11f55b536a565b57531ac114461ae8736d6506a3", "expires_in":43200, "user_id":6492}
```

Class VK::Serverside is deprecate. Please use VK::Application


#### Secure server(deprecated)


```.ruby

app = VK::Secure.new app_id: 222, app_secret: 'secret key'

app.authorize # => {"access_token":"533bacf01e11f55b536a565b57531ac114461ae8736d6506a3"}
```

Class VK::Secure is deprecate. Please use VK::Application


#### Standalone


__Not supported__

Class VK::Standalone is deprecate. Please use VK::Application


## Configuration

Used to configure the gem [attr_configurable](https://github.com/zinenko/attr_configurable)
The idea is the hierarchy of default parameters.

__instance variable__ -> __class constant__ -> __module constant__

```.ruby

module VK
  APP_ID = 111

  class Application
    APP_ID = 222
  end

  class Secure
  end
end

VK::Application.new.app_id # => 222

VK::Application.new(app_id: 333).app_id # => 333

VK::Secure.new.app_id # => 111
```

For configuration available this options:

* __logger__ application logger.
* __verb__ http verb request. Only `:get` or `:post`.
* __access_token__ your access token.
* __open_timeout__  open_timeout request.
* __timeout__ timeout request.
* __proxy__ proxy params request.
* __ssl__ indicating that you need to use ssl.

More information on configuring ssl documentation [faraday](https://github.com/technoweenie/faraday/wiki/Setting-up-SSL-certificates)

### Middlewares

__VK-RUBY__ based on [faraday](https://github.com/technoweenie/faraday).

It is an HTTP client lib that provides a common interface over many adapters (such as Net::HTTP) and embraces the concept of Rack middleware when processing the request/response cycle.

[Advanced middleware usage](https://github.com/technoweenie/faraday#advanced-middleware-usage).

#### Default middlewares stack implementation

```.ruby

def faraday_middleware
  @faraday_middleware || proc do |faraday|
    # request params encoders
    faraday.request  :multipart
    faraday.request  :url_encoded

    # response body parse
    faraday.response :json, content_type: /\bjson$/

    # http adapter
    faraday.adapter  self.adapter
  end
end
```

#### Expanding stack

```.ruby

app.faraday_middleware = proc do |faraday|
  faraday.request  :multipart
  faraday.request  :url_encoded

  faraday.response :json, content_type: /\bjson$/
  faraday.response :normalize_utf     # UTF nfkd normalization
  faraday.response :validate_utf      # Remove invalid utf
  faraday.response :vk_logger, self.logger

  faraday.adapter  app.adapter
end
```

Read more [Middleware usage](https://github.com/technoweenie/faraday#advanced-middleware-usage)

## IRB mode

```.bash

$ vk --help
  -h, --help                       Display this help and exit
  -v, --version                    Output version infomation and exit
  -e, --eval [code]                Evaluate the given code and exit
  -a, --access_token [token]       Your access token
  -t, --type [type]                Application type
  -i, --id [id]                    Application ID
  -s, --secret [secret]            Application secret
  -l, --logfile                    Logfile
  -T, --types                      List application types

$ vk -e 'puts vk.isAppUser'
0

$ vk -a 'your token'
001 > vk.access_token
002 > => "your token"

```

## Contributing to vk-ruby

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 [Andrew Zinenko](http://izinenko.ru). See LICENSE.txt for further details.