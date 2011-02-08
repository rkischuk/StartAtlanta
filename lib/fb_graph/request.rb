module FbGraph
  class Request < Node
    attr_accessor :application, :to, :from, :message, :created_time

    def initialize(identifier, attributes = {})
      super

      @application = Application.new(application.delete(:id), application)
      @from = User.new(from.delete(:id), from)
      @to = User.new(to.delete(:id), to)

      @message = attributes[:message]
      @like_count = attributes[:likes]
      if attributes[:created_time]
        @created_time = Time.parse(attributes[:created_time]).utc
      end
    end
  end


  #{
  #   "id": "138552879540293",
  #   "application": {
  #      "name": "ConnectMe Rob Dev",
  #      "id": "122349161170258"
  #   },
  #   "to": {
  #      "name": "Quilted Norbert",
  #      "id": "100001567445524"
  #   },
  #   "from": {
  #      "name": "Rob Kischuk",
  #      "id": "12822211"
  #   },
  #   "message": "ConnectMe asked me who you'd like to date. I found the perfect person.",
  #   "created_time": "2011-02-03T05:26:25+0000"
  #}
end