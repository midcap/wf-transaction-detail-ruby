require 'account_collection'

describe 'AccountCollection' do
  let(:ac) { TransactionDetail::AccountCollection.new('1234') }
  it 'can have an account added' do
    ac.add_account("4567890")
    expected = {"accounts"=>[{"bank_id"=>"1234", "account_number"=>"4567890"}]}
    expect(ac.to_json).to eq(expected.to_json)
  end

  it 'can be initialized with accounts' do
    ac = TransactionDetail::AccountCollection.new('1234', ['4567890'])
    expected = {"accounts"=>[{"bank_id"=>"1234", "account_number"=>"4567890"}]}
    expect(ac.to_json).to eq(expected.to_json)
  end

  it 'can have an account removed' do
    ac.add_account("123456")
    accts = ac.list_accounts
    expect(accts.length).to eq(1)
    ac.remove_account("123456")
    expect(accts.length).to eq(0)
  end

  it 'can list its accounts' do
    ac.add_account("111111")
    ac.add_account("222222")
    ac.add_account("333333")
    expect(ac.list_accounts).to eq(Set["111111", "222222", "333333"])
  end
end

