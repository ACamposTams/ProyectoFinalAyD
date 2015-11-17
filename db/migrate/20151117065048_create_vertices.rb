class CreateVertices < ActiveRecord::Migration
  def change
    create_table :vertices do |t|
      t.integer :node_a
      t.integer :node_b
      t.float :weight

      t.timestamps null: false
    end
  end
end
