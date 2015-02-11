# -*- encoding: utf-8 -*-

class Array
  unless defined?(:choice)
    alias_method :choice, :sample
  end
end

# for Ruby 2.2.0
# https://github.com/rails/rails/commit/b0acc77edced44e47c8570bf7dddd4ce19f06cb0
class DateTime
  def <=>(other)
    if other.respond_to? :to_datetime
      super other.to_datetime
    else
      nil
    end
  end
end
