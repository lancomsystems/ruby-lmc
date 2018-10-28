require 'test_helper'
class LmcAccountTest < ::Minitest::Test
  TEST_ORGA = 'ruby-lmc'
  TEST_ACCOUNT_NOT_OWNED = 'permanent_test_not_owned'
  TEST_ACCOUNT_NON_UNIQUE = 'permanent_test_non_unique'

  RENAME_ACCOUNT_NAME = 'prerename'
  RENAME_NEW_NAME = "postrename"

  def setup
    @orga = LMC::Account.get_by_name TEST_ORGA
  end

  def teardown
    LMC::Cloud.instance.get_accounts_objects.select {|a| [RENAME_NEW_NAME, RENAME_ACCOUNT_NAME].include? a.name}.each do |a|
      a.delete!
    end
  end

  def test_getting_account_by_id
    cloud = LMC::Cloud.instance
    account_from_list = cloud.get_accounts_objects.first
    account = LMC::Account.get_by_uuid account_from_list.id
    assert_instance_of LMC::Account, account
    assert account_from_list.id == account.id
    assert_equal account_from_list.name, account.name
  end

  def test_getting_account_by_name
    cloud = LMC::Cloud.instance
    account_from_lst = cloud.get_accounts_objects.find {|a| a.name == TEST_ORGA}
    account = LMC::Account.get_by_name account_from_lst.name
    assert_instance_of LMC::Account, account
    assert account_from_lst.id == account.id
  end

  def test_getting_account_by_uuid_or_name
    cloud = LMC::Cloud.instance
    account_from_list = cloud.get_accounts_objects.find {|a| a.name == TEST_ORGA}
    account_by_name = LMC::Account.get_by_uuid_or_name account_from_list.name
    account_by_uuid = LMC::Account.get_by_uuid_or_name account_from_list.id
    assert_instance_of LMC::Account, account_by_uuid
    assert_instance_of LMC::Account, account_by_name
    assert account_from_list.id == account_by_name.id
    assert account_from_list.id == account_by_uuid.id
  end

  def test_getting_account_by_invalid_uuid
    assert_raises RestClient::Forbidden do
      LMC::Account.get_by_uuid_or_name '00000000-0000-0000-96BD-5F97BE22D5F6'
    end
  end

  def test_getting_account_by_invalid_name
    begin
      nonexistant_account = LMC::Account.get_by_uuid_or_name "Nonexistant"
    rescue RuntimeError => e
      assert_equal "Did not find account", e.message
    end
    begin
      nonexistant_account = LMC::Account.get_by_uuid_or_name "Nonexistant account with space"
    rescue RuntimeError => e
      assert_equal "Did not find account", e.message
    end
  end

  def test_getting_account_by_non_unique_name
    exception = assert_raises RuntimeError do
      LMC::Account.get_by_uuid_or_name TEST_ACCOUNT_NON_UNIQUE
    end
    assert_equal 'Account name not unique', exception.message
  end

  def test_account_exists
    good = LMC::Account.get_by_name TEST_ORGA
    bad = LMC::Account.new({name: 'foobar'})
    assert good.exists?
    refute bad.exists?
  end

  def test_getting_account_missing_argument
    err = assert_raises RuntimeError do
      LMC::Account.get_by_uuid_or_name nil
    end
    assert_match(/Missing argument/, err.message)
    err = assert_raises RuntimeError do
      LMC::Account.get_by_uuid nil
    end
    assert_match(/Missing argument/, err.message)
    err = assert_raises RuntimeError do
      LMC::Account.get_by_name nil
    end
    assert_match(/Missing argument/, err.message)
  end

  def test_creating_a_project
    orga = LMC::Account.get_by_name TEST_ORGA
    account = LMC::Account.new({"name" => __method__.to_s,
                                "type" => 'PROJECT',
                                "parent" => orga.id})
    account.save
    refute_nil account.id
  end

  def test_creating_then_deleting_a_project
    currentmillis = (Time.now.to_f * 1000).floor
    unique_name = __method__.to_s + currentmillis.to_s
    begin
      testaccount = LMC::Account.get_by_name unique_name
    rescue RuntimeError => e
      raise e unless e.message == "Did not find account"
    end
    fail unless testaccount.nil?
    orga = LMC::Account.get_by_name TEST_ORGA
    account = LMC::Account.new({"name" => unique_name,
                                "type" => 'PROJECT',
                                "parent" => orga.id})
    account.save
    assert account.delete!
    check_deleted = assert_raises RuntimeError, "Account #{account} not deleted" do
      LMC::Account.get_by_name unique_name
    end
    assert_match(/Did not find account/, check_deleted.message, "Account #{account} not deleted.")
  end

  def test_delete_failure
    account = LMC::Account.get_by_name TEST_ACCOUNT_NOT_OWNED
    error = assert_raises RuntimeError do
      account.delete!
    end
    assert_match(/403 Forbidden/, error.message)
  end

  def test_account_renaming
    @rename_account = LMC::Account.new({'parent' => @orga.id, 'type' => 'PROJECT', 'name' => RENAME_ACCOUNT_NAME})
    @rename_account.save
    pre = LMC::Account.get_by_name RENAME_ACCOUNT_NAME
    pre.name = RENAME_NEW_NAME
    pre.save
    post = LMC::Account.get_by_name RENAME_NEW_NAME
    assert_equal pre.id, post.id
  end

  def test_account_members
    account = LMC::Account.get_by_name TEST_ORGA
    member = account.find_member_by_name LMC::Tests::CredentialsHelper.credentials.ok.email
    members = account.members
    refute_nil member
    refute_empty members
  end

  def test_account_children
    orga = LMC::Account.get_by_name TEST_ORGA
    children = orga.children
    refute_empty children
    assert_instance_of LMC::Account, children.first
  end

  def test_account_logs
    logs = @orga.logs
    refute_empty logs
  end

  def test_authority_by_id
    mock_cloud = Minitest::Mock.new
    mock_cloud.expect :call, {}, [["cloud-service-auth", "accounts", "31FF009A-DC34-4C5B-827F-076DA590EAEF", "authorities", "36D88B55-913C-4DA8-8C64-A42A7C465A8D"]]
    LMC::Cloud.instance.stub :get, mock_cloud do
      account = LMC::Account.new({"id" => "31FF009A-DC34-4C5B-827F-076DA590EAEF"})
      account.authority"36D88B55-913C-4DA8-8C64-A42A7C465A8D"
    end
    assert mock_cloud.verify
  end

end
