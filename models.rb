require 'bundler/setup'
Bundler.require

if development?
    # ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
end

class User < ActiveRecord::Base#大文字の単数形(History)で定義
    has_secure_password
    
    validates :name,
        presence: true,#空欄はだめ
        # uniquness: true,
        format: {
            with:/\A\w+\z/,
        },
        # format: {with:/.+@.+/}#@を含む必要がある
        length: { maximum: 16 }#16文字以下
        
    validates :password,
        length: {in: 6..10}#6文字以上10文字以下
    
    has_many :words#ユーザーが複数のtaskを持つ
end

class Word < ActiveRecord::Base#大文字の単数形(History)で定義
    # scope :due_over, ->{ where('due_date < ?' ,Date.today).where(completed: [nil,false])}
    # scope :had_by, ->(user){ where(user_id: user.id)}
    
    # validates :title,
    #     presence: true#空欄はだめ
    
    belongs_to :user#1つタスクが1人のユーザーに所属する
   
    
    # def remained_days
    #     return (due_date - Date.today).to_i
    # end
end

class Like < ActiveRecord::Base#大文字の単数形(History)で定義
    
end