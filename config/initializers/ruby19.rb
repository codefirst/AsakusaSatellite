# -*- encoding: utf-8 -*-

class Array
  unless defined?(:choice)
    alias_method :choice, :sample
  end
end
