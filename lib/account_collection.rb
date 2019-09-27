require 'set'
require 'json'

module WFTransactionDetail
  class AccountCollection
    def initialize(bank_id, accounts = [])
      @bank_id = bank_id
      @accounts = Set.new(accounts)
    end

    def add_account(account_num)
      if is_number?(account_num)
        @accounts.add(account_num)
      else
        raise ArgumentError, "bank account must be a number"
      end
    end

    def remove_account(account_num)
      @accounts.delete(account_num)
    end

    def list_accounts()
      @accounts
    end

    def as_json(options={})
      obj = { "accounts" => [] }
      @accounts.each do |acct|
        obj['accounts'] << {
          "bank_id" => @bank_id,
          "account_number" => acct.to_s
        }
      end
      obj
    end

    def to_json(*options)
      as_json.to_json(*options)
    end

    private
    def is_number?(number_string)
      true if Integer(number_string) rescue false
    end
  end
end

