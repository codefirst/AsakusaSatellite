class Tweet < ActiveGroonga::Base
  def encode_json(encoder)
    #encoder.escape(self)
    "{'content': '#{content}'}"
  end
#  def encode_json
#    "{'content': '#{self.content}'}"
#  end
end
