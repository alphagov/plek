require_relative "test_helper"

class ProductionLikeTest < Minitest::Test
  def test_environment
    {
      'integration.publishing.service.gov.uk' => :integration,
                                 'dev.gov.uk' => :development,
          'staging.publishing.service.gov.uk' => :staging
    }.each do |domain, expected_environment|
      plek = Plek.new(domain)
      assert_equal expected_environment, plek.environment
    end
  end

  def test_development?
    plek = Plek.new('dev.gov.uk')
    assert_equal true, plek.development?
    plek = Plek.new('integration.gov.uk')
    assert_equal false, plek.development?
  end

  def test_integration?
    plek = Plek.new('integration.gov.uk')
    assert_equal true, plek.integration?
    plek = Plek.new('staging.gov.uk')
    assert_equal false, plek.integration?
  end

  def test_staging?
    plek = Plek.new('staging.gov.uk')
    assert_equal true, plek.staging?
    plek = Plek.new('integration.gov.uk')
    assert_equal false, plek.staging?
  end

  def test_production?
    plek = Plek.new('production.gov.uk')
    assert_equal true, plek.production?
    plek = Plek.new('staging.gov.uk')
    assert_equal false, plek.production?
  end

  def test_production_like_environments
    %w(integration.gov.uk staging.gov.uk production.gov.uk).each do |domain|
      production_like = Plek.new(domain).production_like?
      assert_equal true, production_like, "#{domain} should be production_like?"
    end
  end

  def test_not_production_like_environments
    %w(test.gov.uk dev.gov.uk).each do |domain|
      production_like = Plek.new(domain).production_like?
      assert_equal false, production_like, "#{domain} should not be production_like?"
    end
  end
end
