module LoginHelper
  def login_link
    if Setting[:login_link]
      link_to t(:login), :controller => Setting[:login_link] , :action => 'index'
    else
      link_to t(:login), :controller => 'login', :action => 'oauth'
    end
  end
end
