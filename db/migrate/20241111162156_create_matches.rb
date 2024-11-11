class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.integer :maximum_number_of_games
      t.integer :status

      t.timestamps
    end
  end
end
