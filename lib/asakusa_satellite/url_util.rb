# -*- mode:ruby; coding:utf-8 -*-
module AsakusaSatellite
  module UrlUtil
    def parse(path,&f)
      name,query = path.split('?', 2)
      if name =~ %r!\A/+([^/]+)! then
        name = $1.downcase.to_sym
        params = parse_query(query || '')
        { :name => name, :query => params }
      end
    end

    def parse_query(query)
      alist = query.split('&').map do|x|
        key,name = x.split('=',2)
        [key.downcase.to_sym, name]
      end
      Hash[*alist.flatten]
    end

    module_function :parse,:parse_query
  end
end
