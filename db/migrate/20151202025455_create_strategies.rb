class CreateStrategies < ActiveRecord::Migration
  def change
    create_table :strategies do |t|
    	t.string :strategy

      t.timestamps null: false
    end
  end
end
