require 'transaction_collection'

describe 'TransactionCollection' do
  let(:wf_json_api_response) { {"accounts":[{"bank_id":"091000019","account_number":"10000111111","account_type":"DEMAND_DEPOSIT","account_name":"QUALITY LIFE MUSSMAN CO","currency_code":"USD","transaction_count":10,"transactions":[{"posting_date":"2019-06-04","value_date":"2019-06-04","transaction_datetime":"2019-06-04 03:12:00Z","debit_credit_indicator":"DEBIT","transaction_type":"CHECK","bai_type_code":"045","transaction_description":"BANK ORIGINATED DEBIT FR 0000007186 THE SHERWIN-WILLIAMS COMPANY SUB ACCT 000004944938950","transaction_amount":224.43,"zero_day_float":0,"one_day_float":0,"two_date_float":0,"check_number":"0000","bank_reference":"082300000022","transaction_status":"POSTED"},{"posting_date":"2019-06-04","value_date":"2019-06-04","transaction_datetime":"2019-06-04 02:12:00Z","debit_credit_indicator":"DEBIT","transaction_type":"CHECK","bai_type_code":"045","transaction_description":"BANK ORIGINATED DEBIT FR 0000007186 THE SHERWIN-WILLIAMS COMPANY SUB ACCT 000004944938950","transaction_amount":224.43,"zero_day_float":0,"one_day_float":0,"two_date_float":0,"check_number":"0000","bank_reference":"082300000022","transaction_status":"POSTED"}]},{"bank_id":"091000019","account_number":"10000222222","account_type":"DEMAND_DEPOSIT","account_name":"QUALITY LIFE MUSSMAN II CO","currency_code":"USD","transaction_count":10,"transactions":[{"posting_date":"2019-06-04","value_date":"2019-06-04","transaction_datetime":"2019-06-04 03:12:00Z","debit_credit_indicator":"DEBIT","transaction_type":"CHECK","bai_type_code":"045","transaction_description":"BANK ORIGINATED DEBIT FR 0000007186 THE SHERWIN-WILLIAMS COMPANY SUB ACCT 000004944938950","transaction_amount":224.43,"zero_day_float":0,"one_day_float":0,"two_date_float":0,"check_number":"0000","bank_reference":"082300000022","transaction_status":"POSTED"},{"posting_date":"2019-06-04","value_date":"2019-06-04","transaction_datetime":"2019-06-04 02:12:00Z","debit_credit_indicator":"DEBIT","transaction_type":"CHECK","bai_type_code":"045","transaction_description":"BANK ORIGINATED DEBIT FR 0000007186 THE SHERWIN-WILLIAMS COMPANY SUB ACCT 000004944938950","transaction_amount":224.43,"zero_day_float":0,"one_day_float":0,"two_date_float":0,"check_number":"0000","bank_reference":"082300000022","transaction_status":"POSTED"}]}],"limit":5,"total_count":20,"paging":[{"cursors":[{"previous_cursor":"a488ce6e-54dc-4207-93fb-8444acae07ea10","next_cursor":"a488ce6e-54dc-4207-93fb-8444acae07ea16"}]}],"not_entitled_accounts":{"accounts":{"account_number":[]}}} }
  let(:wf_json_2) { "{\"accounts\":[{\"bank_id\":\"11111111111\",\"account_number\":\"2222222222222\",\"account_type\":\"DEMAND_DEPOSIT\",\"account_name\":\"MIDCAP BUSINESS CREDIT LLC\",\"currency_code\":\"USD\",\"transaction_count\":3,\"transactions\":[{\"posting_date\":\"2019-09-11\",\"value_date\":\"2019-09-11\",\"transaction_datetime\":\"2019-09-11 16:08:56Z\",\"debit_credit_indicator\":\"DEBIT\",\"transaction_type\":\"ACH\",\"bai_type_code\":\"455\",\"transaction_description\":\"COMPANY NAME:  CLIENT ANALYSIS                    SRVC CHRG ENTRY DESC:    SRVC CHRG RECIPIENT ID:   SVC CHGE 0819 RECIPIENT NAME:000004764506150 COMPANY ID:    DP10700543 ENTRY CLASS CODE:   PPD DISCRETIONARY DATA: TRANSACTION CODE: 27\",\"transaction_amount\":253.75,\"zero_day_float\":0.00,\"one_day_float\":0.00,\"two_date_float\":0.00,\"customer_reference_number\":\"091000018762757\",\"transaction_status\":\"RECEIVED\"},{\"posting_date\":\"2019-09-11\",\"value_date\":\"2019-09-11\",\"transaction_datetime\":\"2019-09-11 13:30:51Z\",\"debit_credit_indicator\":\"DEBIT\",\"transaction_type\":\"WIRE\",\"bai_type_code\":\"506\",\"transaction_description\":\"190911041146 000004765495700 MIDCAP BUSINESS CREDIT LLC CONCENTRATION ACCOUNT 433 S MAIN ST STE 212 WEST HA RTFORD CT US 06110-2812 OBI=ACCOUNT TRANSFER /FTR/ Completed Timestamp 190911083038 (Time Released)\",\"transaction_amount\":163649.84,\"zero_day_float\":0.00,\"one_day_float\":0.00,\"two_date_float\":0.00,\"transaction_status\":\"COMPLETE\"},{\"posting_date\":\"2019-09-11\",\"value_date\":\"2019-09-11\",\"transaction_datetime\":\"2019-09-11 12:26:22Z\",\"debit_credit_indicator\":\"CREDIT\",\"transaction_type\":\"WIRE\",\"bai_type_code\":\"195\",\"transaction_description\":\"0911D4B74G1C000114 0911D4B74G1C000114 190911030824 044000024 HUNTINGTON NATIONAL BANK THE HUNTINGTON CENTER 41 S HIGH STREET COLUMBUS, OHIO 20190 91100000810 ORG=ROYAL ICE CREAM CO AKA PIERRES FRENCH ICE CREAM COMP 6200 EUCLID AVE CLEVELAND  OH 44103 OBI=REF: FBO ROYAL ICE CREAM COMPANY DBA PIERRES ICE CREAM CO OPI=01668343962 /FTR/ BNF=4764506150 MIDCAP BUSINESS CREDIT LLC FBO ROYAL ICE CREAM 433 SOUTH MAIN ST WEST HARTFORD CT 06110 Completed Timestamp 190911072613 (Time Released)\",\"transaction_amount\":163108.42,\"zero_day_float\":0.00,\"one_day_float\":0.00,\"two_date_float\":0.00,\"transaction_status\":\"COMPLETE\"}]},{\"bank_id\":\"11111111111\",\"account_number\":\"33333333333333\",\"account_type\":\"DEMAND_DEPOSIT\",\"account_name\":\"MIDCAP BUSINESS CREDIT LLC\",\"currency_code\":\"USD\",\"transaction_count\":3,\"transactions\":[{\"posting_date\":\"2019-09-11\",\"value_date\":\"2019-09-11\",\"transaction_datetime\":\"2019-09-11 16:08:56Z\",\"debit_credit_indicator\":\"DEBIT\",\"transaction_type\":\"ACH\",\"bai_type_code\":\"455\",\"transaction_description\":\"COMPANY NAME:  CLIENT ANALYSIS                    SRVC CHRG ENTRY DESC:    SRVC CHRG RECIPIENT ID:   SVC CHGE 0819 RECIPIENT NAME:000004744710146 COMPANY ID:    DP10700543 ENTRY CLASS CODE:   PPD DISCRETIONARY DATA: TRANSACTION CODE: 27\",\"transaction_amount\":252.53,\"zero_day_float\":0.00,\"one_day_float\":0.00,\"two_date_float\":0.00,\"customer_reference_number\":\"091000018761979\",\"transaction_status\":\"RECEIVED\"},{\"posting_date\":\"2019-09-11\",\"value_date\":\"2019-09-11\",\"transaction_datetime\":\"2019-09-11 13:30:13Z\",\"debit_credit_indicator\":\"DEBIT\",\"transaction_type\":\"WIRE\",\"bai_type_code\":\"506\",\"transaction_description\":\"190911040915 000004765495700 MIDCAP BUSINESS CREDIT LLC CONCENTRATION ACCOUNT 433 S MAIN ST STE 212 WEST HA RTFORD CT US 06110-2812 OBI=ACCOUNT TRANSFER /FTR/ Completed Timestamp 190911083005 (Time Released)\",\"transaction_amount\":39882.09,\"zero_day_float\":0.00,\"one_day_float\":0.00,\"two_date_float\":0.00,\"transaction_status\":\"COMPLETE\"},{\"posting_date\":\"2019-09-11\",\"value_date\":\"2019-09-11\",\"transaction_datetime\":\"2019-09-11 12:06:08Z\",\"debit_credit_indicator\":\"CREDIT\",\"transaction_type\":\"WIRE\",\"bai_type_code\":\"206\",\"transaction_description\":\"190911029133 000004126195569 PROFUSION INDUSTRIES, LLC 822 KUMHO DR STE 202 FAIRLAWN OH US 44333-8334 OBI=P ROFUSION INDUSTRIES LLC /FTR/ Completed Timestamp 190911070601 (Time Released)\",\"transaction_amount\":39358.40,\"zero_day_float\":0.00,\"one_day_float\":0.00,\"two_date_float\":0.00,\"transaction_status\":\"COMPLETE\"}]}],\"limit\":50,\"total_count\":6,\"paging\":[{}]}" }

  describe 'Created from JSON' do
    let(:tc) { JSON.parse(wf_json_api_response.to_json, object_class: WFTransactionDetail::Collection, create_additions: true) }

    it 'is a valid WFTransactionDetail::Collection object' do
      expect(tc.kind_of?(WFTransactionDetail::Collection)).to be true
      tc2 = JSON.parse(wf_json_2, object_class: WFTransactionDetail::Collection, create_additions: true)
      expect(tc2.kind_of?(WFTransactionDetail::Collection)).to be true
    end

    it 'can access accounts' do
      expect(tc.list_accounts).to eq([10000111111, 10000222222])
      expect(tc.account(10000111111).account_number).to eq("10000111111")
      expect(tc.account(10000111111).account_name).to eq("QUALITY LIFE MUSSMAN CO")
    end

    it 'can access transactions' do
      expect(tc.transactions(10000111111).length).to eq(2)
      expect(tc.transactions(10000111111)[0].transaction_amount).to eq(224.43)
      expect(tc.transactions(10000111111)[1].transaction_amount).to eq(224.43)
    end

    it 'can access paging cursors' do
      expect(tc.next_cursor).to eq("a488ce6e-54dc-4207-93fb-8444acae07ea16")
      expect(tc.prev_cursor).to eq("a488ce6e-54dc-4207-93fb-8444acae07ea10")
    end

    it 'cursor methods return nil when no cursors are found' do
      tc2 = JSON.parse(wf_json_2, object_class: WFTransactionDetail::Collection, create_additions: true)
      expect(tc2.next_cursor).to be_nil
      expect(tc2.prev_cursor).to be_nil
    end

    it 'can convert account to hash' do
      expected = {:bank_id=>"091000019", :account_number=>"10000111111", :account_type=>"DEMAND_DEPOSIT", :account_name=>"QUALITY LIFE MUSSMAN CO", :currency_code=>"USD", :transaction_count=>10, :transactions=>[{"posting_date"=>"2019-06-04", "value_date"=>"2019-06-04", "transaction_datetime"=>"2019-06-04 03:12:00Z", "debit_credit_indicator"=>"DEBIT", "transaction_type"=>"CHECK", "bai_type_code"=>"045", "transaction_description"=>"BANK ORIGINATED DEBIT FR 0000007186 THE SHERWIN-WILLIAMS COMPANY SUB ACCT 000004944938950", "transaction_amount"=>224.43, "zero_day_float"=>0, "one_day_float"=>0, "two_date_float"=>0, "check_number"=>"0000", "bank_reference"=>"082300000022", "transaction_status"=>"POSTED"}, {"posting_date"=>"2019-06-04", "value_date"=>"2019-06-04", "transaction_datetime"=>"2019-06-04 02:12:00Z", "debit_credit_indicator"=>"DEBIT", "transaction_type"=>"CHECK", "bai_type_code"=>"045", "transaction_description"=>"BANK ORIGINATED DEBIT FR 0000007186 THE SHERWIN-WILLIAMS COMPANY SUB ACCT 000004944938950", "transaction_amount"=>224.43, "zero_day_float"=>0, "one_day_float"=>0, "two_date_float"=>0, "check_number"=>"0000", "bank_reference"=>"082300000022", "transaction_status"=>"POSTED"}]}
      acct_num = tc.list_accounts[0]
      acct = tc.account(acct_num)
      expect(acct.to_h).to eq(expected)
    end

    it 'can convert transaction to hash' do
      expected = {"posting_date"=>"2019-06-04", "value_date"=>"2019-06-04", "transaction_datetime"=>"2019-06-04 03:12:00Z", "debit_credit_indicator"=>"DEBIT", "transaction_type"=>"CHECK", "bai_type_code"=>"045", "transaction_description"=>"BANK ORIGINATED DEBIT FR 0000007186 THE SHERWIN-WILLIAMS COMPANY SUB ACCT 000004944938950", "transaction_amount"=>224.43, "zero_day_float"=>0, "one_day_float"=>0, "two_date_float"=>0, "check_number"=>"0000", "bank_reference"=>"082300000022", "transaction_status"=>"POSTED"}
      acct_num = tc.list_accounts[0]
      trans = tc.transactions(acct_num)
      expect(trans[0].to_h).to eq(expected)
    end
  end
end

