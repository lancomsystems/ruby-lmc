# frozen_string_literal: true

require 'test_helper'
class LmcConfigstatesTest < Minitest::Test
  ACCOUNT_NAME = 'ruby-lmc'

  def test_initializer
    states = LMC::Configstates.new('ACTUAL' => 7, 'OUTDATED' => 19)
    assert states.actual == 7
    assert states.outdated == 19
  end

  def test_initializer_with_defaults
    states = LMC::Configstates.new({})
    assert states.actual == 0
    assert states.outdated == 0
  end

  def test_getting_account_configstates
    account = LMC::Account.get_by_name ACCOUNT_NAME
    configstates = account.config_updatestates
    empty_states = LMC::Configstates.new({})
    assert_equal empty_states.actual, configstates.actual
    assert_equal empty_states.outdated, configstates.outdated
  end
end

