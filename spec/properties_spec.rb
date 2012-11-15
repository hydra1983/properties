require 'spec_helper'
require 'properties'

prop = Properties::Properties.new

describe "#load" do
  prop.load(File.expand_path("../data/test.properties",__FILE__))
  
  context "\"empty_proeprty=  \"" do
    it "should be empty" do
      prop.empty_property.should eq("")
    end
  end

  context "\"sample_property= sample property \"" do
    it "should be \"sample property\"" do
      prop.sample_property.should eq("sample property")
    end
  end
end