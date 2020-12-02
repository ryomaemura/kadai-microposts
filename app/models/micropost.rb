class Micropost < ApplicationRecord
  belongs_to :user
  
  validates :content, presence: true, length: { maximum: 255 }
  
  # 投稿をお気に入りしたユーザーを参照する中間テーブル
  has_many :reverses_of_favorite, class_name: 'Favorite'
  # 投稿をお気に入りしたユーザーを取得する
  has_many :favorite_by_users, through: :reverses_of_favorite, source: :user
end