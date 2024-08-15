# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Fortymm.Repo.insert!(%Fortymm.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Fortymm.Accounts

seeds = Application.get_env(:fortymm, :seeds)

development_users = [
  %{
    username: "First User",
    email: "first_test_user@test.test",
    password: "first_test_user_password"
  },
  %{
    username: "Second User",
    email: "second_test_user@test.test",
    password: "second_test_user_password"
  },
  %{
    username: "Third User",
    email: "third_test_user@test.test",
    password: "third_test_user_password"
  },
  %{
    username: "Fourth User",
    email: "fourth_test_user@test.test",
    password: "fourth_test_user_password"
  }
]

if Keyword.get(seeds, :users, false) do
  development_users
  |> Enum.filter(&(Accounts.get_user_by_email(&1.email) == nil))
  |> Enum.each(&Accounts.register_user(&1))
end
