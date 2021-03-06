
require 'sinatra/base'
require 'rack-flash'
require 'pony'
require 'data_mapper'
require 'dm-core'
require 'dm-migrations'
require 'sass'
require 'timecop'


require_relative 'helpers/currentuser'
require_relative 'helpers/peeps'
require_relative 'data_mapper_setup'

DataMapper.auto_upgrade!

class ChitterAPI < Sinatra::Base

  helpers CurrentUser
  helpers PeepHelpers

  enable :sessions
  set :sessions_secret, 'super secret'
  use Rack::Flash
  use Rack::MethodOverride

  get '/' do
    @user = User.get(session[:user_id])
    # @peeps = Peep.all.sort{|a,b| a.peep_timestamp <=> b.peep_timestamp }
    erb :signup
  end

  get '/contact' do
    @title = "Contact Chitter"
    erb :contact
  end

  post '/contact' do
    session[:user_id]
    if send_message
      flash[:notice] = "Thank you for your message. We'll be in touch soon."
      redirect to ('/')
    else 
      flash[:notice] = "Sorry, something was wrong with your form"
      erb :contact
      redirect to ('/contact')
    end
  end

  get '/users/new' do
    @title = "Create a New User"
    @user = User.new
    erb :signup
  end

  post '/users' do
    @user = User.create(:username => params[:username],
                     :email => params[:email],
                     :password => params[:password],
                     :password_confirmation => params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "Welcome to Chitter, #{@user.username}"
      redirect ('/sessions/new')
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :signup
    end
  end

  get '/sessions/new' do
    @title = "Sign in"
    erb :signin
  end

  post '/sessions' do
    username, password = params[:username], params[:password]
    @user = User.authenticate(username, password)
    if @user
     session[:user_id] = @user.id
     flash[:notice] = "Welcome back, #{@user.username}"
     redirect ('/')
    else 
      flash[:errors] = ["The username and password you entered did not match our records. Please double-check and try again."]
      redirect('/sessions/new')
   end
  end

  get '/sessions/logout' do
    if session[:user_id]
      session[:user_id] = nil
      flash[:notice] = "You are now logged out"
      redirect to('/')
    else 
      flash[:notice] = "You are not logged in"
      redirect to ('/')
    end
  end

  get '/peep' do
    @peeps = Peep.all
    erb :peep
  end

  post '/peep/new' do
      protected!
      @user = User.get(session[:user_id])
      @peep = Peep.new(:message => params[:message],
                       :username => @user.username,
                       :peep_timestamp => time_stamp(Time.now))
    if @peep.message == ""
      flash[:notice] = "You didn't enter a peep"
      redirect ('/')
    else
      flash[:notice] = "You posted a new peep"
      @peep.save
      redirect to("/")
    end

  end

  get '/peep/:id' do
    @peep = Peep.get(params[:id])
    erb :show_peep
  end

   put '/peep/:id' do
    peep = Peep.get(params[:id])
    peep.update(params[:peep])
    flash[:notice] = "Peep successfully updated"
    redirect to("/peep/#{peep.id}")
  end

  get '/peep/:id/edit' do
    protected!
    correct_user!
    @peep = Peep.get(params[:id])
    erb :edit_peep
  end

  delete '/peep/:id' do
    protected!
    correct_user!
    @peep = Peep.get(params[:id])
    @peep.destroy
    flash[:notice] = "Peep deleted"
    redirect ('/')
  end

  post '/peep' do
    if @peep = peep.create(params[:peep])
      flash[:notice] = "Peep successfully added"
      redirect to("/peep/#{@peep.id}")
    end
  end


  not_found do
    puts "not found"
    erb :not_found
  end

 run! if app_file == $0

end

