require 'open-uri'

class TweetsController< ApplicationController
  respond_to :json, :xml
  def index
    @tweets = Tweet.all
    respond_with(@tweets)
  end

  def create
    Tweet.new(:content => params[:content]).save
    fork {
      system 'curl http://0.0.0.0:8081/publish'
    }
    redirect_to :controller => 'chat', :action => 'tweet'
  end
  alias_method :new, :create
end
