require File.dirname(__FILE__) + '/../spec_helper'

describe AsakusaSatellite do
  subject { AsakusaSatellite::VERSION }
  it { should_not be_nil }
end
