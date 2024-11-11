require "test_helper"

class MatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    match = matches(:one)
    get match_url(match)
    assert_response :success
  end
end
