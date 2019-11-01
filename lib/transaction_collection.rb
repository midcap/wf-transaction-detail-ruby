require 'json'
require 'active_support/core_ext/object/try'
require 'forwardable'

module WFTransactionDetail

  def initialize_instance_variables(o)
    o.data.each do |key, value|
      instance_variable_set("@#{key}", value)
      self.class.send(:attr_reader, key)
    end
  end

  # Intended to be used with the built in JSON parser
  # e.g. JSON.parse(data.to_json, object_class: TransactionDetail::Collection, create_additions: true)
  # would return an instance of this object
  class Collection
    extend Forwardable

    def_delegators :@data, :account, :list_accounts, :transactions, :next_cursor, :prev_cursor
    attr_accessor :data

    # initialize arg must be optional because the first time it is called by the JSON parser
    # it will be called with an empty constructor
    def initialize(o = nil)
      # JSON.create_id defaults to 'json_class' and the JSON parser will use this value when first called
      # to initialize an object of this type
      @data = {
        JSON.create_id => self.class.name
      }
      if o != nil && o.kind_of?(WFTransactionDetail::Collection)
        initialize_accounts(o.data)
        initialize_pages(o.data)
      end
    end

    def json_creatable?
      true
    end

    def [](index)
     @data[index]
    end

    def []=(index, new_value)
      @data[index] = new_value
    end

    def self.json_create(o)
      # Once the initial object is created we don't need to keep creating this property
      o.data.delete(JSON.create_id)
      if is_account?(o.data)
        return WFTransactionDetail::Account.new(o)
      end
      if is_transaction?(o.data)
        return WFTransactionDetail::Transaction.new(o)
      end
      if is_cursor?(o.data)
        return parse_cursor(o.data)
      end
      new(o)
    end

    def list_accounts
      @data[:account_array]
    end

    def account(account_number)
      @data[:accounts][account_number]
    end

    def transactions(account_number)
      an = account_number.to_i
      @data[:accounts][an].transactions
    end

    def next_cursor
      @data[:paging]["next_cursor"]
    end

    def prev_cursor
      @data[:paging]["previous_cursor"]
    end

    private
    def self.is_account?(obj)
      account_identifiers = %w[bank_id account_number transactions]
      return (obj.keys & account_identifiers).any?
    end

    def self.is_transaction?(obj)
      transaction_identifiers = %w[posting_date transaction_amount transaction_status]
      return (obj.keys & transaction_identifiers).any?
    end

    def self.is_cursor?(obj)
      cursor_identifiers = %w[previous_cursor next_cursor cursors]
      return (obj.keys & cursor_identifiers).any?
    end

    def self.parse_cursor(obj)
      # This function is responsible for parsing the paging portion of the JSON response
      # it is structured as a nested object so json_create will be called once for each object found

      # The tricky thing about this approach for a complex object such as this is
      # EVERY object needs to be handled, when the JSON parser hits curly braces it enters
      # json_create() so an object either needs to be parsed and returned or thrown away.
      # This means two main things:
      # 1) You have to do some very customized parsing based on your JSON structure
      # 2) The structure of the JSON response will either make things easy or difficult

      # Expected JSON structure for cursor parser:
      # "paging": [
      #   {
      #       "cursors": [
      #           {
      #               "previous_cursor": "a488ce6e-54dc-4207-93fb-8444acae07ea10",
      #               "next_cursor": "a488ce6e-54dc-4207-93fb-8444acae07ea16"
      #           }
      #       ]
      #    }
      # ],
      obj.keys.each do |k|
        if k.include?("next") || k.include?("previous")
          # Handle this object:
          # {
          #   "previous_cursor": "a488ce6e-54dc-4207-93fb-8444acae07ea10",
          #   "next_cursor": "a488ce6e-54dc-4207-93fb-8444acae07ea16"
          # }
          return obj
        end
        if obj.key?("cursors")
          # Handle this object:
          # {
          #   "cursors": [
          #     {...}
          #   ]
          # }
          return obj["cursors"][0]
        end
      end
    end

    def initialize_accounts(obj)
      if obj.key?('accounts') && obj['accounts'].kind_of?(Array)
        @data[:accounts] = {}
        @data[:account_array] = []
        obj['accounts'].each do |a|
          @data[:account_array] << a.account_number.to_i
          @data[:accounts][a.account_number.to_i] = a
        end
      end
    end

    def initialize_pages(obj)
      if obj.key?('paging') && obj['paging'].kind_of?(Array)
        @data[:paging] = obj['paging'][0]
      end
    end
  end

  class Account
    include WFTransactionDetail
    def initialize(o)
      initialize_instance_variables(o)
    end
    def to_h
      vars = instance_variables.map do |key|
        variable = instance_variable_get(key)
        if variable.respond_to? :to_h
          if variable.kind_of?(Array)
            variable = variable.map { |var| var.to_h }
          else
            variable = variable.to_h
          end
        end
        [key.to_s[1..-1].to_sym, variable]
      end
      Hash[vars]
    end
  end

  class Transaction
    include WFTransactionDetail
    def initialize(o)
      initialize_instance_variables(o)
    end
    def to_h
      instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = instance_variable_get(var) }
    end
  end
end

