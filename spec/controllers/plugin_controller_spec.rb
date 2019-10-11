# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require 'fileutils'

describe PluginController do
  test_root = Rails.root + 'plugins/imaginary_plugin/'
  test_path = test_root + 'app/assets/javascripts/'

  context "ファイルが存在するとき" do
    before do
      FileUtils.mkdir_p test_path
      FileUtils.touch(test_path+"some.js")
    end

    describe "get" do
      before { get 'asset', :params => { :plugin => 'imaginary_plugin', :type => 'javascript', :file => 'some', :format => 'js' } }
      subject { response }
      it { should be_success }
    end
  end

  context "ファイルが存在しないとき" do
    before do
      FileUtils.rm_r test_root
    end

    describe "get" do
      before { get 'asset', :params => { :plugin => 'imaginary_plugin', :type => 'javascript', :file => 'some', :format => 'js' } }
      subject { response }
      it { should_not be_success }
    end
  end

  context "外部のファイルを取得しようとしたとき" do
    describe "attempt to get secret file" do
      describe "bad plugin name" do
        before { get 'asset', :params => { :plugin => '..', :type => 'javascript', :file => 'application', :format => 'js' } }
        subject { response }
        it { should_not be_success }
      end

      describe "bad type name" do
        before { get 'asset', :params => { :plugin => 'imaginary_plugin', :type => '../../../../app/assets/javascript', :file => 'application', :format => 'js' } }
        subject { response }
        it { should_not be_success }
      end

      describe "bad file name" do
        before { get 'asset', :params => { :plugin => 'imaginary_plugin', :type => 'javascript', :file => '../../../../../README', :format => 'markdown' } }
        subject { response }
        it { should_not be_success }
      end
    end
  end
end
