require File.dirname(__FILE__) + '/../spec_helper'
require 'yaml'

describe Setting do
  before do 
    @settings = YAML.load(File.open("#{Rails.root}/config/settings.yml"))
  end

  it "各設定を読める" do
    @settings.each do |key, value|
      Setting[key].should == value
    end
  end
end

