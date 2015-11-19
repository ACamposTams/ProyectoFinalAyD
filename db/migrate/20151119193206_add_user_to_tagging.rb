class AddUserToTagging < ActiveRecord::Migration
  def change
  	add_reference :taggings, :user, index: true
  	add_foreign_key :taggings, :users
  end
end
