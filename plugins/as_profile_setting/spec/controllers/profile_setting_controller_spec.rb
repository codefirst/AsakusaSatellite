# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'

describe ProfileSettingController do
  before do
    @user = User.new(:profile_image_url => "http://example.com/profile.png").tap{|u| u.save! }
    @room1 = Room.new(:title => 'test1').tap{|r| r.save! }
    @room2 = Room.new(:title => 'test2').tap{|r| r.save! }
  end

  describe "ログインしていない場合はエラーになる" do
    before { put :update }
    subject { response }
    it {
      should redirect_to :controller => 'chat', :action => 'index'
    }
  end

  describe "1つめのプロファイル追加" do
    before do
      session[:current_user_id] = @user.id
      put(:update,
          :room => {"id" => @room1._id},
          :account => { "name" => "user1", "image_url" => "http://example.com/pic1.jpg" })
    end

    describe "プロファイルを追加する" do
      before { @modified_user = User.where(:_id => @user._id).first }

      describe "成功する" do
        subject { response }
        it {
          should redirect_to :controller => 'account'
        }
      end

      describe "新規作成される" do
        subject { @modified_user.user_profiles }
        it { should have_exactly(1).items }
      end

      describe "値が正しく設定される" do
        subject { @modified_user.user_profiles[0] }
        its(:name) { should == "user1" }
        its(:profile_image_url) { should == "http://example.com/pic1.jpg" }
        its(:room_id) { should == @room1._id }
      end

      describe "デフォルトのプロファイルは変更されない" do
        subject { @modified_user }
        its(:name) { should == @user.name }
        its(:profile_image_url) { should == @user.profile_image_url }
      end


      describe "2つめのプロファイルを追加する" do
        before {
          session[:current_user_id] = @user.id
          put(:update,
              :room => {"id" => @room2._id},
              :account => { "name" => "user2", "image_url" => "http://example.com/pic2.jpg" })
        }

        describe "プロファイルを追加する" do
          before { @modified_user = User.where(:_id => @user._id).first }

          describe "成功する" do
            subject { response }
            it {
              should redirect_to :controller => 'account'
            }
          end

          describe "新規作成される" do
            subject { @modified_user.user_profiles }
            it { should have_exactly(2).items }
          end

          describe "値が正しく設定される" do
            subject { @modified_user.user_profiles[1] }
            its(:name) { should == "user2" }
            its(:profile_image_url) { should == "http://example.com/pic2.jpg" }
            its(:room_id) { should == @room2._id }
          end

          describe "1つめのプロファイルは変更されない" do
            subject { @modified_user.user_profiles[0] }
            its(:name) { should == "user1" }
            its(:profile_image_url) { should == "http://example.com/pic1.jpg" }
          end

          describe "1つめのプロファイルを変更する" do
            before {
              session[:current_user_id] = @user.id
              put(:update,
                  :room => {"id" => @room1._id},
                  :account => { "name" => "user3", "image_url" => "http://example.com/pic3.jpg" })
            }

            describe "プロファイルを追加する" do
              before { @modified_user = User.where(:_id => @user._id).first }

              describe "成功する" do
                subject { response }
                it {
                  should redirect_to :controller => 'account'
                }
              end

              describe "新規作成されない" do
                subject { @modified_user.user_profiles }
                it { should have_exactly(2).items }
              end

              describe "値が正しく更新される" do
                subject { @modified_user.user_profiles[0] }
                its(:name) { should == "user3" }
                its(:profile_image_url) { should == "http://example.com/pic3.jpg" }
                its(:room_id) { should == @room1._id }
              end

              describe "2つめのプロファイルは変更されない" do
                subject { @modified_user.user_profiles[1] }
                its(:name) { should == "user2" }
                its(:profile_image_url) { should == "http://example.com/pic2.jpg" }
              end
            end
          end

          describe "1つめのプロファイルを削除する" do
            before {
              session[:current_user_id] = @user.id
              put(:update,
                  :room => {"id" => @room1._id},
                  :remove =>  "Remove")
            }

            describe "プロファイルを追加する" do
              before { @modified_user = User.where(:_id => @user._id).first }

              describe "成功する" do
                subject { response }
                it {
                  should redirect_to :controller => 'account'
                }
              end

              describe "削除される" do
                subject { @modified_user.user_profiles.length }
                it { should be 1 }
              end
            end
          end
        end
      end
    end
  end
end
