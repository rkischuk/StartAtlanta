require 'fb_graph'

module FbGraph
  class Request < Node
    attr_accessor :application, :data, :to, :from, :message, :created_time

    def initialize(identifier, attributes = {})
      super

      unless attributes[:application].nil?
        @application = Application.new(attributes[:application].delete(:id), attributes[:application])
      end
      @data = attributes[:data]
      @from = User.new(attributes[:from].delete(:id), attributes[:from]) if attributes[:from]
      @to = User.new(attributes[:to].delete(:id), attributes[:to]) if attributes[:to]
      @message = attributes[:message]
      @created_time = Time.parse(attributes[:created_time]).utc if attributes[:created_time]
    end
  end
end