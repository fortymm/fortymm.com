require "application_system_test_case"

class LandingPageTest < ApplicationSystemTestCase
  test "visiting the landing page" do
    visit landing_page_index_url

    assert_selector "h1", text: "FortyMM"
  end
end
