require File.dirname(__FILE__) + '/../spec_helper'

describe ChatController do
  describe "発言投稿時は" do
    before do
      user = User.new
      user.save
      session[:current_user_id] = user.id
    end

    it "一件messageが増える" do
      lambda {
        room = Room.new(:title => 'test')
        room.save!
        message = 'テストメッセージ'
        post :message, {:room_id => room.id, :message => message}
      }.should change(Message.all.records, :size).by(1)
    end

    it "部屋がない場合はエラーメッセージとなる" do
      room = Room.new(:title => 'test')
      room.save
      room.delete
      lambda {
        post(:message, {:room_id => room.id, :message => 'テストメッセージ'})
      }.should raise_error
    end
  end

  describe "発言一覧時は" do
    it "デフォルトで該当する部屋のメッセージの20件を取得する" do
      room = Room.new(:title => 'test')
      room.save
      50.times do
        Message.new(:room => room).save
      end
      get :room, {:id => room.id}
      assigns[:messages].records.size.should == 20
    end
  end

  describe "発言更新時は" do
    it "該当メッセージの内容が更新される" do
      owner = User.new
      owner.save
      session[:current_user_id] = owner.id
      message = Message.new(:body => 'init', :user => owner)
      message.save
      post :update_message_on_the_spot, {:id => message.id, :value => 'modified'}
      Message.find(message.id).body.should == 'modified'
    end

    it "該当メッセージを作成したユーザ以外は変更できない" do
      owner = User.new
      owner.save
      other = User.new
      other.save
      session[:current_user_id] = other.id
      message = Message.new(:body => 'init', :user => owner)
      message.save
      post :update_message_on_the_spot, {:id => message.id, :value => 'modified'}
      Message.find(message.id).body.should == 'init'
    end

  end

  describe "部屋作成時は" do
    it "ログインしていない場合は作成しない" do
      session[:current_user_id] = nil 
      room_num = Room.all.records.size
      post :room, {:room => {:title => 'test'}}
      Room.all.records.size.should == room_num
    end

    it "ログインしていない場合はトップページへリダイレクトする" do
      session[:current_user_id] = nil 
      room_num = Room.all.records.size
      post :room, {:room => {:title => 'test'}}
      response.should redirect_to(:controller => 'chat', :action => 'index')
    end

    it "ログインしていないユーザが/chat/createへアクセスするとトップページにリダイレクトする" do
      session[:current_user_id] = nil 
      get :create
      response.should redirect_to(:controller => 'chat', :action => 'index')
    end

    it "一件roomが増える" do
      owner = User.new
      owner.save
      session[:current_user_id] = owner.id
      title = 'テスト部屋'
      post :room, {:room => {:title => title}}
      assigns[:room].title.should == title
    end
  end


  it "index アクセス時は削除されていない部屋が表示される" do
    Room.all.each {|room| room.delete}
    Room.new(:title => 'test').save
    Room.new(:title => 'test', :deleted => true).save
    get :index
    assigns[:rooms].each {|room| room.deleted.should be_false}
    assigns[:rooms].records.size.should == 1
  end

  it "show アクセス時は前後n件が表示される" do
    room = Room.new
    room.save
    10.times { Message.new(:room => room).save }
    message = Message.new(:room => room)
    message.save
    10.times { Message.new(:room => room).save }
    get :show, :id => message.id, :c => 5
    assigns[:messages].size.should == 11
  end

  context "部屋の名前の変更" do
    before do
      @owner = User.new
      @owner.save
      @room = Room.new(:title => 'init', :user => @owner)
      @room.save

    end
    it "オーナーは部屋の名前を変更できる" do
      session[:current_user_id] = @owner.id
      post :update_attribute_on_the_spot, :id => "room__title__#{@room.id}", :value => 'modified'
      Room.find(@room.id).title.should == 'modified'
    end

    it "オーナー以外のユーザは部屋の名前を変更できない" do
      user = User.new
      user.save
      session[:current_user_id] = user.id
      lambda {
        post :update_attribute_on_the_spot, :id => "room__title__#{@room.id}", :value => 'modified'
      }.should raise_error
    end

    it "空文字の時は更新しない" do
      session[:current_user_id] = @owner.id
      post :update_attribute_on_the_spot, :id => "room__title__#{@room.id}", :value => ''
      Room.find(@room.id).title.should == 'init'
    end

  end
end
