# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../spec_helper'

describe Api::V1::ServiceController do
  before {
    get :info, :params => { :format => 'json' }
  }
  subject { response.body }
  it { should have_json("/message_pusher") }
  it { should have_json("/message_pusher/name") }
  it { should have_json("/message_pusher/param") }
  it { should_not have_json("/message_pusher/param/secret") }
end
