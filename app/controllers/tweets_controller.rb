class TweetsController< ApplicationController
  respond_to :json, :xml
  def index 
    @tweets = Tweet.all
    respond_with(@tweets)
  end

  def create
    Tweet.new(:content => params[:content]).save
    redirect_to :controller => 'chat', :action => 'tweet'
  end
  alias_method :new, :create
end
