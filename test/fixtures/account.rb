# frozen_string_literal: true
module Fixtures
  def self.test_project(cloud = Fixtures.mock_lmc)
    LMC::Account.new cloud, 'id' => '56f6253d-4dd6-4a48-adfa-02a390aa6e84',
                     'name' => 'Some lame test project',
                     'type' => 'PROJECT'
  end
  def self.test_orga(cloud = Fixtures.mock_lmc)
    LMC::Account.new cloud, 'id' => '049019a7-ea1c-401e-8713-85cf15821e0e',
                     'name' => 'Some lame test orga',
                     'type' => 'ORGANIZATION'
  end
end