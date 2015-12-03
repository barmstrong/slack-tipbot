$LOAD_PATH.unshift(File.dirname(__FILE__))

Dir["initializers/*.rb"].each {|file| require file }
require 'slack-ruby-client'
Dir["commands/*.rb"].each {|file| require file }
require 'web'
require 'oauth2'
require 'coinbase/wallet'
require 'tipbot'

Thread.new do
  begin
    Tipbot.new.run
  rescue Exception => e
    STDERR.puts "ERROR: #{e}"
    STDERR.puts e.backtrace
    raise e
  end
end

run Web
