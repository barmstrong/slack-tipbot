require 'sinatra/base'

class Web < Sinatra::Base
  get '/' do
    "I'm alive!"
  end
end
