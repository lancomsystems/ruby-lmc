require 'test_helper'
class LmcAuthActionTest < Minitest::Test
  def test_action_post
    mock_cloud = Minitest::Mock.new
    a = LMC::AuthAction.new mock_cloud
    a.name = "test@example.com"
    a.type = LMC::AuthAction::ACCOUNT_DELETE
    a.data = {'accountId' => 'abe29447-8bf9-4b9f-a004-37ae8370001d', 'password' => "FOObar123?"}
    mock_cloud.expect :post, {}, [["cloud-service-auth", "actions"], a]
    a.post
    mock_cloud.verify
  end
end