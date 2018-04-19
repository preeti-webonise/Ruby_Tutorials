class Post < ApplicationRecord
  validates :content, length: { maximum: 15 }, presence: true
  validates :user_id, presence: true 
  belongs_to :user
end
