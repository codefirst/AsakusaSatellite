module GlobalJsCssSettingHelper
  def shorten_string(str, pre_length, post_length)
    if str.length < (pre_length + post_length)
      str
    else
      str[0..pre_length-1] + " ... " + str[-post_length..-1]
    end
  end
end
