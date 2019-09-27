require 'forwardable'

module WFTransactionDetail
  class HTTPError < StandardError
    extend Forwardable

    def_delegator :@response, :code
    attr_reader :response, :message

    def initialize(response)
      @response = response
      @message = response.try(:message) || response.try(:body)
    end
  end
end
