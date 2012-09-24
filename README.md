#VK-RUBY [![Build Status](https://secure.travis-ci.org/zinenko/vk-ruby.png)](http://travis-ci.org/zinenko/vk-ruby)

Ruby wrapper for vk.com API. Compatible with Ruby 1.9.2, 1.9.3, Jruby and RBX.

[documentation](http://rubydoc.info/github/zinenko/vk-ruby/master/frames)

## Installation

```.bash

gem install vk-ruby
```

## How to use

### API method calling

```.ruby

app = VK::Serverside.new access_token: TOKEN

app.audio.search q: 'Sting' # => Sting tracks

# similar call

app.vk_call 'audio.search", {q: 'Sting'}
```

### Upload files

```.ruby

url = 'http://cs2222.vkontakte.ru/upload.php?act=do_add'

VK.upload(url: url, photo: ['/path/to/example.jpg', 'image/jpeg'])
```

### Authorization

#### Serverside

```.ruby

app = VK::Serverside.new app_id: 222, app_secret: 'secret key'

app.authorize(CODE) # => {"access_token":"533bacf01e11f55b536a565b57531ac114461ae8736d6506a3", "expires_in":43200, "user_id":6492}
```

#### Secure server

```.ruby

app = VK::Secure.new app_id: 222, app_secret: 'secret key'

app.authorize # => {"access_token":"533bacf01e11f55b536a565b57531ac114461ae8736d6506a3"}
```

#### Standalone

__Not supported__

## Configuration

__instance variable__ -> __class constant__ -> __module constant__

```.ruby

module VK
  APP_ID = 111

  class Serverside
    APP_ID = 222
  end

  class Secure
  end
end

VK::Serverside.new.app_id # => 222

VK::Serverside.new(app_id: 333).app_id # => 333

VK::Secure.new.app_id # => 111
```

### Middlewares stack

#### Default middlewares stack implementation

```.ruby

def faraday_middleware
  @faraday_middleware || proc do |faraday|
    faraday.request  :multipart
    faraday.request  :url_encoded
    faraday.response :json, content_type: /\bjson$/
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
  faraday.response :normalize_utf
  faraday.response :validate_utf
  faraday.response :vk_logger, self.logger

  faraday.adapter  app.adapter
end
```

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

$ vk -a 'your token'

1.9.3p194 :001 > vk.access_token
 => "your token"

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