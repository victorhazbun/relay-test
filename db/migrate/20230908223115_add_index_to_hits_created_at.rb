class AddIndexToHitsCreatedAt < ActiveRecord::Migration[7.0]
  def change
    add_index :hits, :created_at
  end
end
