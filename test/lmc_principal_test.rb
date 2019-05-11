# frozen_string_literal: true

require 'test_helper'
class LmcPrincipalTest < Minitest::Test
  def setup
    @principal_id = 'a35fe21b-1605-431a-bf1e-88d087f48cc0'
    @principal = LMC::Principal.new id: @principal_id, name: 'foobar', password: 'secret', type: 'test'
  end

  def test_get_self
    mock_get = Minitest::Mock.new
    mock_get.expect :call, Fixtures.test_response({}), [[['cloud-service-auth', 'users'], 'self']]
    LMC::Cloud.instance.stub :get, mock_get do
      principal = LMC::Principal.get_self LMC::Cloud.instance
      assert_kind_of LMC::Principal, principal
    end
    assert_mock mock_get
  end

  def test_saving_principal
    p = LMC::Principal.new name: 'foobar', password: 'secret', type: 'test'
    mock_post = Minitest::Mock.new
    mock_post.expect :call, Fixtures.test_response({ id: @principal_id }),
                     [['cloud-service-auth', 'principals'], LMC::Principal]
    LMC::Cloud.instance.stub :post, mock_post do
      saved_principal = p.save
      assert_equal @principal_id, saved_principal.id
      assert_equal @principal_id, p.id
      # saving a principal with existing ID is not supported
      assert_raises RuntimeError do
        p.save
      end
    end

  end

  def test_to_s
    u = @principal
    assert_equal 'foobar - a35fe21b-1605-431a-bf1e-88d087f48cc0', u.to_s
    refute_match 'secret', u.to_s
  end

  def test_to_json
    assert_equal '{"name":"foobar","type":"test","password":"secret"}', @principal.to_json
  end
end
