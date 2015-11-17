class AddTagsToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :tags, :string, array: true, default: '{}'
  end
end
