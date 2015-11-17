class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.integer :node_id
      t.integer :num_vertices

      t.timestamps null: false
    end
  end
end
