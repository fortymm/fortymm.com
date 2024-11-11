require "test_helper"

class MatchTest < ActiveSupport::TestCase
  test "is valid with valid attributes" do
    assert matches(:one).valid?
  end

  test "is not valid without a maximum number of games" do
    match = matches(:one)
    match.maximum_number_of_games = nil
    assert_not match.valid?
  end

  test "is not valid when maximum number of games is not in [1, 3, 5, 7]" do
    (1..100)
      .filter { |number| ![ 1, 3, 5, 7 ].include?(number) }
      .each do |number|
        match = matches(:one)
        match.maximum_number_of_games = number
        assert_not match.valid?
    end
  end

  test "is valid when maximum number of games is in [1, 3, 5, 7]" do
    [ 1, 3, 5, 7 ].each do |number|
      match = matches(:one)
      match.maximum_number_of_games = number
      assert match.valid?
    end
  end

  test "is not valid without a status" do
    match = matches(:one)
    match.status = nil
    assert_not match.valid?
  end

  test "is not valid when status is not in [:pending, :in_progress, :finished, :cancelled, :stopped]" do
    match = matches(:one)
    match.status = "invalid"
    assert_not match.valid?
  end
end
