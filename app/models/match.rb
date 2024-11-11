class Match < ApplicationRecord
  validates :maximum_number_of_games, presence: true, inclusion: { in: [ 1, 3, 5, 7 ] }
  enum :status, %w[pending in_progress finished cancelled stopped], default: :pending, validate: true
end
