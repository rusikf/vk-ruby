#VK-RUBY
[![Build Status](https://secure.travis-ci.org/zinenko/vk-ruby.png)](http://travis-ci.org/zinenko/vk-ruby)

Ruby wrapper for vk.com API.
VK-RUBY is compatible with Ruby 1.9.2, 1.9.3 and RBX.

## Installation

```
gem install vk-ruby
```

## Example

```.ruby
# Serverside Application
require 'vk-ruby'

app = VK::Serverside.new app_id: APP_ID, app_secret: APP_SECRET

app.audio.search(q: 'Sting').map{|track| puts track.inspect}  if app.authorize CODE
# => Sting tracks
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

<<<<<<< HEAD
Copyright (c) 2011-2012 Andrew Zinenko. See LICENSE.txt for further details.
=======
Copyright (c) 2011 [Andrew Zinenko](http://izinenko.ru). See LICENSE.txt for further details.
>>>>>>> ebdc3c009522a4a7ad3afa3cd10e5c3c4bbc344b
