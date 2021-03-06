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
