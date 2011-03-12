module Api
  module V1
    class RoomController < ApplicationController
      include ChatHelper

      before_filter :check_spell, :only => [:create, :update, :destroy]

      respond_to :json
      def show
        count = if params[:count] then
                  params[:count].to_i
                else
                  20
                end
        if params[:until_id] then
          message = Message.find params[:until_id]
          @messages = message.prev(count-1)
          @messages << message
        else
          room = Room.find(params[:id])
          @messages = room.messages(count)
        end
        respond_with(@messages.map{|m| to_json(m) })
      end

      def create
        unless logged?
          render :json => {:status => 'error', :error => 'login not yet'}
          return
        end
        room = Room.new(:title => params[:name], :user => current_user, :updated_at => Time.now)
        if room.save
          render :json => {:status => 'ok'}
        else
          render :json => {:status => 'error', :error => "room creation failure"}
        end
      end

      def update
        unless logged?
          render :json => {:status => 'error', :error => 'login not yet'}
          return
        end
        room = Room.find(params[:id])
        if room.nil?
          render :json => {:status => 'error', :error => "room not found"}
        end
        room.title = params[:name]
        if room.save
          render :json => {:status => 'ok'}
        else
          render :json => {:status => 'error', :error => "room creation failure"}
        end
      end

      def destroy
        unless logged?
          render :json => {:status => 'error', :error => 'login not yet'}
          return
        end
        room = Room.find(params[:id])
        if room.nil?
          render :json => {:status => 'error', :error => "room not found"}
        end
        room.deleted = true
        if room.save
          render :json => {:status => 'ok'}
        else
          render :json => {:status => 'error', :error => "room deletion failure"}
        end
      end

      def list
        rooms = Room.select do |record|
          record.deleted == false
        end.to_a
        #render :json => {:hoge => 'hoge'}
        #respond_with(rooms.map{|r| to_json(r) })
        render :json => rooms.map {|r| r.to_json }
      end

      private
      def check_spell
        if params[:api_key]
          users = User.select do |record|
            record.spell == params[:api_key]
          end
          if users and users.first
            session[:current_user_id] = users.first.id
          end
        end
      end


    end
  end
end
