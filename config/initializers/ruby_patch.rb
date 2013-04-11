# -*- encoding: utf-8 -*-

class Array
  unless defined?(:choice)
    alias_method :choice, :sample
  end
end

class CGI
  class << self
    alias_method :orig_escapeHTML, :escapeHTML
    def escapeHTML(str)
      orig_escapeHTML(str).gsub("'", "&#39;")
    end
  end
end if RUBY_VERSION < '2.0.0'

