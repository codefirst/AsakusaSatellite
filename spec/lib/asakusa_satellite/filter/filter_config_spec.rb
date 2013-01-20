require File.dirname(__FILE__) + '/../../../spec_helper'

describe AsakusaSatellite::Filter::FilterConfig do
  before :all do
  end

  describe "with array" do
    describe "with empty array" do
      before do
        @filter_config = AsakusaSatellite::Filter::FilterConfig.new([])
      end

      describe 'filters' do
        subject { @filter_config.filters }
        it { should == [] }
      end

      describe 'plugins' do
        subject { @filter_config.plugins }
        it { should == [] }
      end

      describe 'plugins_dirs' do
        subject { @filter_config.plugins_dirs }
        it { should include("as_code_highlight_filter") }
      end
    end

    describe "with array" do
      before do
        @filter_config = AsakusaSatellite::Filter::FilterConfig.new([{"name"=>"foo"}])
      end

      describe 'filters' do
        subject { @filter_config.filters }
        it { should == [{"name"=>"foo"}] }
      end

      describe 'plugins' do
        subject { @filter_config.plugins }
        it { should == [{"name"=>"foo"}] }
      end

      describe 'plugins_dirs' do
        subject { @filter_config.plugins_dirs }
        it { should include("as_code_highlight_filter") }
      end
    end
  end

  describe "with hash" do
    describe "with empty hash" do
      before do
        @filter_config = AsakusaSatellite::Filter::FilterConfig.new({})
      end

      describe 'filters' do
        subject { @filter_config.filters }
        it { should == [] }
      end

      describe 'plugins' do
        subject { @filter_config.plugins }
        it { should == [] }
      end

      describe 'plugins_dirs' do
        subject { @filter_config.plugins_dirs }
        it { should == [] }
      end
    end

    describe "with hash" do
      before do
        yaml = <<YAML
filters:
 - name: foo
   dir: as_foo

plugins:
 - name: only_name
 - name: name_and_dir
   dir: as_name_dir
 - dir: only_dir
YAML
        hash = YAML::load(yaml)
        @filter_config = AsakusaSatellite::Filter::FilterConfig.new(hash)
      end

      describe 'filters' do
        subject { @filter_config.filters }
        it { should == [{"dir"=>"as_foo","name"=>"foo"}] }
      end

      describe 'plugins' do
        subject { @filter_config.plugins }
        it { should == [{"dir"=>"as_foo","name"=>"foo"},{"name"=>"only_name"},{"dir"=>"as_name_dir","name"=>"name_and_dir"}] }
      end

      describe 'plugins_dirs' do
        subject { @filter_config.plugins_dirs }
        it { should == ["as_foo","as_only_name","as_name_dir","only_dir"] }
      end
    end
  end
end


