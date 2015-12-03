require 'sinatra/base'
require 'commands'

class Web < Sinatra::Base

  include Commands

  get '/' do
    "I'm alive!"
  end

  post '/tip' do
    content_type :json
    puts params.to_s
    resp = case params['text'].split[0].downcase
    when 'help'
      help(params)
    when 'bal', 'balance'
      balance(params)
    when /^@\w/
      send(params)
    when 'balance'
      balance(params)
    else
      default(params)
    end
    resp.to_json
  end

  get '/oauth2/callback' do
    puts params
    # client.auth_code.authorize_url(:redirect_uri => "#{ENV['REDIRECT_URL']}/oauth2/callback", :scope => 'commands')
    token = slack_client.auth_code.get_token(params['code'], :redirect_uri => "#{ENV['REDIRECT_URL']}/oauth2/callback")
    save_token(params['team_domain'], token)
    "ok"
  end
end
