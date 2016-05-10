#let Bundler handle all requires
require 'bundler'
Bundler.require(:default)

class PageUnliker < Sinatra::Application

	ConfigEnv.init("#{__dir__}/config/secret.rb")

	# register your app at facebook to get those infos
	# your app id
	APP_ID     = ENV["fb_id"]
	# your app secret
	APP_SECRET = ENV["fb_secret"]

  use Rack::Session::Cookie, secret: 'dassomegoodsecretrighthere'

  get '/' do
    erb :"likes.html", layout: :"layout.html"
  end

  get '/logout' do
    session['oauth'] = nil
    session['access_token'] = nil
    redirect '/'
  end

  get '/privacy' do
  	erb :"privacy.html", layout: :"layout.html"
  end
end

