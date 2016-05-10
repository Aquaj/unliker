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
    if session['access_token']
      'You are logged in! <a href="/logout">Logout</a>'
      @graph = Koala::Facebook::API.new(session["access_token"])
      # publish to your wall (if you have the permissions)
      @likes = @graph.graph_call("/me/likes")
      # or publish to someone else (if you have the permissions too ;) )
      # @graph.put_wall_post("Checkout my new cool app!", {}, "someoneelse's id")
      @session = session['access_token']
      erb :"likes.html", layout: :"layout.html"
    else
      '<a href="/login">Login</a>'
    end
  end

  get '/login' do
    # generate a new oauth object with your app data and your callback url
    session['oauth'] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, "#{request.base_url}/callback")
    # redirect to facebook to get your code
    redirect session['oauth'].url_for_oauth_code(permissions: "user_likes")
  end

  get '/logout' do
    session['oauth'] = nil
    session['access_token'] = nil
    redirect '/'
  end

  #method to handle the redirect from facebook back to you
  get '/callback' do
    #get the access token from facebook with your code
    p session['access_token']
    session['access_token'] = session['oauth'].get_access_token(params[:code])
    redirect '/'
  end

  get '/privacy' do
  	erb :"privacy.html", layout: :"layout.html"
  end
end

