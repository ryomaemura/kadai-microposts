class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  # お気に入り投稿の中間テーブル
  has_many :favorites
  # ユーザーがお気に入りした投稿を取得する
  has_many :favorite_posts, through: :favorites, source: :micropost
  
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  # 投稿をお気に入りするメソッド
  def favorite(micropost)
    self.favorites.find_or_create_by(micropost_id: micropost.id)
  end
  
  # 投稿のお気に入りを解除するメソッド
  def unfavorite(micropost)
    unfavorite_micropost = self.favorites.find_by(micropost_id: micropost.id)
    unfavorite_micropost.destroy if unfavorite_micropost
  end
  
  # お気に入り登録しているかを確認するメソッド
  # 登録済ならtrue 未登録ならfalse を返す
  def favorite?(micropost)
    self.favorite_posts.include?(micropost)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
end
