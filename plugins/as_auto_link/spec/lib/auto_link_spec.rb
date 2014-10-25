# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'auto_link'

describe AsakusaSatellite::Filter::AutoLink do
  before do
    @filter = AsakusaSatellite::Filter::AutoLink.new({})
  end

  it 'URLにリンクを貼る' do
    @filter.process('http://example.com').should have_xml("//a[@href='http://example.com']")
  end

  it "httpsについても動作する" do
    @filter.process('https://example.com').should have_xml("//a[@href='https://example.com']")
  end

  it "前後に文字があっても動作する" do
    @filter.process('ほげhttp://example.com').should have_xml("//a[@href='http://example.com']")
    @filter.process('ほげhttp://example.com/abc').should have_xml("//a[@href='http://example.com/abc']")
    @filter.process('ほげhttp://example.com/abc/efg ふが').should have_xml("//a[@href='http://example.com/abc/efg']")
  end

  describe 'twitpicを展開する' do
    subject { @filter.process('http://twitpic.com/3gy2dn') }
    it { should have_xml("//a[@href='http://twitpic.com/3gy2dn']") }
    it { should have_xml("//img[@src='http://twitpic.com/show/thumb/3gy2dn']") }
  end

  describe 'はてなフォトライフを展開する' do
    subject { @filter.process('http://f.hatena.ne.jp/mallowlabs/20130315155811') }
    it { should have_xml("//a[@href='http://f.hatena.ne.jp/mallowlabs/20130315155811']") }
    it { should have_xml("//img[@src='http://img.f.hatena.ne.jp/images/fotolife/m/mallowlabs/20130315/20130315155811_120.jpg']") }
  end

  describe 'Gyazo を展開する' do
    subject { @filter.process('http://gyazo.com/29fe3c362e185d162ac5417a98e98bea') }
    it { should have_xml("//a[@href='http://gyazo.com/29fe3c362e185d162ac5417a98e98bea']") }
    it { should have_xml("//img[@src='http://gyazo.com/29fe3c362e185d162ac5417a98e98bea.png']") }
  end

  describe 'Dropbox を展開する' do
    subject { @filter.process('http://dl.dropbox.com/u/000000/american.png') }
    it { should have_xml("//a[@href='http://dl.dropbox.com/u/000000/american.png']") }
    it { should have_xml("//img[@src='http://dl.dropbox.com/u/000000/american.png']") }
  end

  describe 'img.ly を展開する' do
    subject { @filter.process('http://img.ly/8ZGj') }
    it { should have_xml("//a[@href='http://img.ly/8ZGj']") }
    it { should have_xml("//img[@src='http://img.ly/show/thumb/8ZGj']") }
  end

  describe 'niconico を展開する' do
    subject { @filter.process('http://www.nicovideo.jp/watch/sm20610463') }
    it { should have_xml("//a[@href='http://www.nicovideo.jp/watch/sm20610463']") }
    it { should have_xml("//img[@src='http://tn-skr.smilevideo.jp/smile?i=20610463']") }
  end

  describe 'YouTube を展開する' do
    subject { @filter.process('http://www.youtube.com/watch?v=243vPl8HdVk') }
    it { should have_xml("//a[@href='http://youtu.be/243vPl8HdVk']") }
    it { should have_xml("//img[@src='http://i.ytimg.com/vi/243vPl8HdVk/hqdefault.jpg']") }
  end

  describe 'Instagram を展開する' do
    subject { @filter.process('http://instagr.am/p/YFQ6OmHHi1/') }
    it { should have_xml("//a[@href='http://instagr.am/p/YFQ6OmHHi1']") }
    it { should have_xml("//img[@src='http://instagr.am/p/YFQ6OmHHi1/media/?size=t']") }
  end

  describe 'jpgを展開する' do
    subject { @filter.process('http://www.example.com/foo.jpg') }
    it { should have_xml("//a[@href='http://www.example.com/foo.jpg']") }
    it { should have_xml("//img[@src='http://www.example.com/foo.jpg']") }
  end
end
