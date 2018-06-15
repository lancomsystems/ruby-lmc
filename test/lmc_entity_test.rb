require 'test_helper'
class LmcEntityTest < Minitest::Test
    def test_square_brackets_accessor
        ent = LMC::Entity.new
        assert_equal ent.class, ent['class']
    end
end
