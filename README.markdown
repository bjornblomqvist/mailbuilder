# mailbuilder

A simple ERB based email template thingy! The nice thing is that it inlines the images =).

## Usage


__build_test_email.rb__

```
  # encoding: utf-8

  require "#{File.dirname(__FILE__)}/../lib/mail_builder.rb"

  mail = MailBuilder.new("#{File.dirname(__FILE__)}/emails/test").build({:name => "Björn Blomqvist"})
  mail.subject "Just another test"
  mail.to "me@me.com"
  mail.from "you@you.com"

  File.open("/tmp/test.eml",'w') do |file|
    file.write(mail.to_s)
  end

  puts "Wrote the email to: /tmp/test.eml"
```

__emails/test/test.txt.erb__

```
  Just a simple test

  <%= name %>
```


__emails/test/test.html.erb__

```
  <body bgimage="darwin.png">
    <h1>Just a simple test</h1>

    <%= name %>

    <img src="darwin.png" >

    <p style="background: url(darwin.png)">
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    </p>

    <p background="darwin.png">
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    </p>

  </body>
```



## Contributing to mailbuilder
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Darwin. See LICENSE.txt for
further details.

