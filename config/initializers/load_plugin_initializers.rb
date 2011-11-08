Dir::glob(File::dirname(__FILE__) + "/../plugins/vendor/*/config/initializers/*.rb") do |file|
  puts file
end
