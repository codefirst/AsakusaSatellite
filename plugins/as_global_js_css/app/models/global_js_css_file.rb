class GlobalJsCssFile
  include Mongoid::Document
  field :url
  field :type

  def self.javascripts
    GlobalJsCssFile.where(:type => "javascript").to_a
  end

  def self.csss
    GlobalJsCssFile.where(:type => "css").to_a
  end
end
