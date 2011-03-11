module Api
  module V1
    class RoomController < ApplicationController
      include ChatHelper

      before_filter :check_spell, :only => [:create, :update, :destroy]

      respond_to :json
      def show
        room = Room.find(params[:id])
        if params[:since_date]
          @messages = Message.select do |record|
            [
              record.created_at >= params[:since_date].to_date.beginning_of_day.to_i,
              record.room == room
            ]
          end
        elsif params[:until_id]
          @messages = Message.select do |record|
            [
             record._id.to_i < params[:until_id].to_i,
             record.room == room
            ]
          end.
            sort([{:key => "created_at", :order => :desc}], :limit => params[:count] || 20).
            to_a.reverse.map{|x| x.to_hash }
        elsif params[:offset]
          begin
            @messages = Message.select do |record|
              record.room == room
            end.sort([{:key => 'created_at', :order => :desc}],
                     :limit => (params[:count] ? params[:count].to_i : nil) || 20,
                     :offset => params[:offset].to_i).
                     to_a.reverse
          rescue Groonga::TooLargeOffset
            @messages = []
          end
        else
          @messages = Message.select do|record|
            record.room == room
          end
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
        logger.info params[:id]
        room = Room.find(params[:id])
        room.title = params[:name]
        if room.save
          render :json => {:status => 'ok'}
        else
          render :json => {:status => 'error', :error => "room creation failure"}
        end
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
