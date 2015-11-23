class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :events, :through => :events_user
  has_many :events_user

  has_many :taggings
  has_many :tags, :through => :taggings

  def all_tags=(names)
  		self.tags = names.split(",").map do |name|
      		tag = Tag.where(name: name.strip).first_or_create!
          # self.taggings.create(tag: tag) if tag.valid?
  		end
      #self.taggings_ids = self.tags.pluck(:id)
      #self.save
	end

	def all_tags
  		self.tags.map(&:name).join(", ")
	end

	def self.tagged_with(name)
  		Tag.find_by_name!(name).users
	end

end
