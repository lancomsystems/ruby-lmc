require "test_helper"

class LmcTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::LMC::VERSION
  end

  def test_it_does_something_useful
    assert ::LMC.useful
  end
end
