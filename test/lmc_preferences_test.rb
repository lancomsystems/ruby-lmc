# frozen_string_literal: true
require 'test_helper'

class LmcPreferencesTest < ::Minitest::Test
  def setup
    @lmc = Fixtures.cloud
  end

  def test_preferences_get
    prefs = @lmc.preferences ['principal', 'self', 'ui']

    mock_get = Minitest::Mock.new
    mock_get.expect :call, Fixtures.test_response(['foobar']) do |path, params|
      assert_equal ['cloud-service-preferences', 'principal', 'self', 'ui'], path
      assert_equal({ path: 'something' }, params)
      true
    end
    @lmc.stub :get, mock_get do
      result = prefs.get('something')
      assert_equal ['foobar'], result
    end
    mock_get.verify
  end

  def test_preferences_put
    prefs = @lmc.preferences ['principal', 'self', 'ui']
    mock_put = Minitest::Mock.new
    mock_put.expect :call, Fixtures.test_response(true), [
        ['cloud-service-preferences', 'principal', 'self', 'ui'],
        'thevalue',
        { path: 'something' }
    ]
    @lmc.stub :put, mock_put do
      prefs.put('something', 'thevalue')
    end
    mock_put.verify
  end
end

