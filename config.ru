$LOAD_PATH.unshift(File.dirname(__FILE__))

Dir["initializers/*.rb"].each {|file| require file }
Dir["commands/*.rb"].each {|file| require file }
require 'web'
require 'oauth2'
require 'coinbase/wallet'
require 'tipbot'
require 'uri'

Thread.new do
  begin
    Tipbot.new.run
  rescue Exception => e
    STDERR.puts "ERROR: #{e}"
    STDERR.puts e.backtrace
    raise e
    retry
  end
end

run Web
