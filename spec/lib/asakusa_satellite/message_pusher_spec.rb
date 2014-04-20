# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../spec_helper'

describe AsakusaSatellite::MessagePusher do
  describe AsakusaSatellite::MessagePusher::Pusher do
    before {
      opt = {'key' => 'API_KEY'}
      @pusher = AsakusaSatellite::MessagePusher::Pusher.new(opt)
    }
    subject { @pusher }
    its (:jsFiles) { should == ['https://d3dy5gmtp8yhk7.cloudfront.net/2.2/pusher.min.js'] }
    its (:jsClass) { should == "new Pusher('API_KEY')" }
  end

  describe AsakusaSatellite::MessagePusher::Keima do
    before {
      opt = {'key' => 'API_KEY', 'url' => 'http://www.example.com'}
      @pusher = AsakusaSatellite::MessagePusher::Keima.new(opt)
    }
    subject { @pusher }
    its (:jsFiles) { should == ['http://www.example.com/socket.io/socket.io.js',
                       'http://www.example.com/javascripts/keima.js'] }
    its (:jsClass) { should =~ /new Keima\('API_KEY'\)/ }
  end

  describe AsakusaSatellite::MessagePusher::Socky do
    before {
      opt = {'http' => 'http', 'web_socket' => 'ws://localhost', 'app' => 'socky'}
      @pusher = AsakusaSatellite::MessagePusher::Socky.new(opt)
    }
    subject { @pusher }
    its (:jsFiles) { should == ['http://js.socky.org/v0.5.0-beta1/socky.min.js'] }
    its (:jsClass) { should =~ /ws:\/\/localhost\/socky/m }
  end

end
