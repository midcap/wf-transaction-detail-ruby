require 'forwardable'

module WFTransactionDetail
  class HTTPError < StandardError
    extend Forwardable

    def_delegator :@response, :code
    attr_reader :response, :my_message, :body

    def initialize(response)
      @body = nil
      @my_message = ""
      @response = response
      unless response.try(:message).empty?
        @my_message = "#{response.message}: "
      end
      if response.try(:body)
        begin
          @my_message << "#{response.body}"
          @body = JSON.parse(response.body)
        rescue JSON::ParserError
          @body = response.body
        end
      end
      super @my_message
    end
  end
end
