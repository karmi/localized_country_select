require 'test/unit'

require 'rubygems'
require 'active_support'
require 'action_controller'
require 'action_controller/test_process'
require 'action_view'
require 'i18n'

require 'localized_country_select'

class LocalizedCountrySelectTest < Test::Unit::TestCase

  include ActionView::Helpers::FormOptionsHelper

  def test_action_view_should_include_helper
    assert ActionView::Helpers::FormBuilder.instance_methods.include?('localized_country_select')
    assert ActionView::Helpers::FormOptionsHelper.instance_methods.include?('localized_country_select')
  end

  def test_should_return_select_tag_with_proper_name
    # puts localized_country_select(:user, :country)
    assert localized_country_select(:user, :country) =~ Regexp.new(Regexp.escape('<select id="user_country" name="user[country]">'))
  end

  def test_should_return_option_tags
    assert localized_country_select(:user, :country) =~ Regexp.new(Regexp.escape('<option value="ES">Spain</option>'))
  end

  def test_should_return_localized_option_tags
    I18n.locale = 'cz'
    assert localized_country_select(:user, :country) =~ Regexp.new(Regexp.escape('<option value="ES">Španělsko</option>'))
  end

  def test_should_return_priority_countries_first
    assert localized_country_options_for_select(nil, [:ES, :CZ]) =~ Regexp.new(
      Regexp.escape("<option value=\"ES\">Spain</option>\n<option value=\"CZ\">Czech Republic</option><option value=\"\" disabled=\"disabled\">-------------</option>\n<option value=\"AF\">Afghanistan</option>\n"))
  end

  def test_i18n_should_know_about_countries
    assert_equal 'Spain', I18n.t('ES', :scope => 'countries')
    I18n.locale = 'cz'
    assert_equal 'Španělsko', I18n.t('ES', :scope => 'countries')
  end

  def test_localized_countries_array_returns_correctly
    assert_nothing_raised { LocalizedCountrySelect::localized_countries_array() }
    # puts LocalizedCountrySelect::localized_countries_array.inspect
    I18n.locale = 'en-US'
    assert_equal 266, LocalizedCountrySelect::localized_countries_array.size
    assert_equal 'Afghanistan', LocalizedCountrySelect::localized_countries_array.first[0]
    I18n.locale = 'cz'
    assert_equal 250, LocalizedCountrySelect::localized_countries_array.size
    assert_equal 'Afghánistán', LocalizedCountrySelect::localized_countries_array.first[0]
  end

  def test_priority_countries_returns_correctly_and_in_correct_order
    assert_nothing_raised { LocalizedCountrySelect::priority_countries_array([:TW, :CN]) }
    I18n.locale = 'en-US'
    assert_equal [ ['Taiwan', 'TW'], ['China', 'CN'] ], LocalizedCountrySelect::priority_countries_array([:TW, :CN])
  end

  private

  def setup
    ['cz', 'en-US'].each do |locale|
      # NOTE : Beware, that this is the old way of loading locale for current gem version,
      #        Rails version uses the <tt>I18n.load_path += []</tt> way
      I18n.load_translations( File.join(File.dirname(__FILE__), '..', 'locale', "#{locale}.rb")  )
    end
    I18n.locale = I18n.default_locale
  end

end
