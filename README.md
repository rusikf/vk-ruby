#VK-RUBY
[![Build Status](https://secure.travis-ci.org/zinenko/vk-ruby.png)](http://travis-ci.org/zinenko/vk-ruby)

Ruby wrapper for vk.com API.

__VK-RUBY__ gives you full access to all API features.
Has several types of method naming and methods calling, optional authorization, file uploading, logging, irb integration, parallel method calling and any faraday-supported http adapter of your choice.

To get started working with vk.com API.
First of all, to [register](http://vk.com/editapp?act=create) your own application and obtain the keys.
Read [vk api documentation](http://vk.com/developers.php).

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

app.adapter = :em_http # or :em_synchrony or :patron or :typhoeus

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

```

### Authorization

[VK](vk.com) has several types of applications and several types of authorization. They are different ways of authorization and access rights.
more details refer to the [documentation](http://vk.com/developers.php?oid=-1&p=%D0%90%D0%B2%D1%82%D0%BE%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F)

#### Site

```.ruby

```


#### Standlalone (Client)

```.ruby

```


#### Server

```.ruby

```

## Configuration


```.ruby

```

More information on configuring ssl documentation [faraday](https://github.com/technoweenie/faraday/wiki/Setting-up-SSL-certificates)

### Middlewares

__VK-RUBY__ based on [faraday](https://github.com/technoweenie/faraday).

It is an HTTP client lib that provides a common interface over many adapters (such as Net::HTTP) and embraces the concept of Rack middleware when processing the request/response cycle.

[Advanced middleware usage](https://github.com/technoweenie/faraday#advanced-middleware-usage).

#### Default middlewares stack implementation

```.ruby

```

#### Expanding stack

```.ruby

```

Read more [Middleware usage](https://github.com/technoweenie/faraday#advanced-middleware-usage)

## Contributing to vk-ruby

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.

## Copyright

Copyright (c) 2014 [Andrew Zinenko](http://izinenko.ru). See LICENSE.txt for further details.