# patch to fix ActiveSupport:JSON::Encoding does not support emoji
module ActiveSupport
  module JSON
    module Encoding
      class << self
        def escape_with_json_gem(string)
          ::JSON.generate([string], :ascii_only => true)[1..-2]
        end
        alias_method_chain :escape, :json_gem
      end
    end
  end
end

