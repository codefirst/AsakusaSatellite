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
      open('curl http://0.0.0.0:8081/publish'){|_|}
    }
    redirect_to :controller => 'chat', :action => 'tweet'
  end
  alias_method :new, :create
end
