require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'open-uri'
require 'net/http'
require 'json'
require 'nokogiri'
require 'selenium-webdriver'

# require 'chromedriver-helper'if production?

require 'sinatra/activerecord'
require './models'

enable :sessions#セッション機能

helpers do
    def current_user
        User.find_by(id: session[:user])#idがsession[:user]の人を1人だけ見つける
    end
    
    def like
       Like.all 
    end
end

before '/home,/search,/' do
    if current_user.nil?
        redirect '/'
    end#ログインしてない時にtodoを押すとtopページに戻るように
end

get '/' do
    erb :index
    # url = 'https://life-is-tech.com/'#html情報をurlから取得
    # html = open(url).read #Nokogiriを使うために専用の形に変換(parse)
    # parsed_html = Nokogiri::HTML.parse(html,nil,'utf-8')#スクレイピング
    # parsed_html.to_html
    
    # parsed_html.css('ul.supporter-list').css('li').each do |node|#多分ページ替わった
    #     #ul.supporter-listタグの中のliタグを全て取得
    #     anchor = node.css('a')
    #     anchor.to_html
    #     logger.info anchor.attribute('href').value
    # end
    
    # parsed_html.css('li').each do |node|#多分ページ替わった
    #     #ul.supporter-listタグの中のliタグを全て取得
    #     anchor = node.css('a')
    #     anchor.to_html
    #     # logger.info anchor.attribute('href').value
    # end
end

get '/signup' do #新規登録の情報入力ページに飛ばす
    @users = []
    User.all.each do |user|
       @users.push(user.name) 
    end

    erb :sign_up
end

post '/signup' do
    user = User.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
    )
    
    if user.persisted?
        session[:user] = user.id #userと言うキーにuser.idを入れる
    end
    redirect '/'
end

get '/signin' do #新規登録の情報入力ページに飛ばす
    erb :sign_in
end

post '/signin' do #サインインのデータを受け取りパスワード正しいか認証
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect '/'
end

get '/signout' do
    session[:user] =nil
    redirect '/'
end

get '/home' do #新規登録の情報入力ページに飛ばす
    @words = Word.where(user_id: current_user.id)
    # @words = []#検索語の初期化
    
    # @tables.each do |word|
    #     @words 
        
    # end
    
    erb :home
end

get '/search' do
    @word = params[:searchWord]#検索語
    
    #検索語が空だったら元に戻す
    if @word.empty?
       redirect '/' 
    end
    
    #配列初期化
    @gooSpeeches= []
    @gooMeanings1= []#意味の文章(インデックスも混じっている)
    
    @gooNumbers= []#意味の文章のインデックス
    @gooMeanings= []#意味の文章
    
    
    @enHackSpeeches= []#品詞の数
    @enHackNumbers= []#意味の文章のインデックス
    @enHackMeanings= []#意味の文章
    @enHackJPs= []#意味の文章(日本語)
    
    #Selenium起動
    Selenium::WebDriver::Chrome.path = ENV.fetch('GOOGLE_CHROME_BIN', nil)
    
    options = Selenium::WebDriver::Chrome::Options.new(
        prefs: { 'profile.default_content_setting_values.notifications': 2 },
        binary: ENV.fetch('GOOGLE_CHROME_SHIM', nil)
    )
    
    
    options.add_argument('headless')
    # options.add_argument('--no-sandbox')
#options.add_argument('--disable-gpu')これ入れるとバグる
    driver = Selenium::WebDriver.for :chrome, options: options
    
    # caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {binary: "/app/.apt/usr/bin/google-chrome", args: ["--headless"]})
    # driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
    
    
    #goo辞書にアクセスする
    driver.get("https://dictionary.goo.ne.jp/word/en/#{@word}")
    # driver.implicitly_wait(10)  # 見つからないときは、10秒まで待つ
    sleep 0.1
    
    # ターミナルへページタイトルを出力
    # puts driver.title
    
    #品詞を取ってくる
    gooHinshi_s = driver.find_elements(:css,"div.content-box > .header-hinshi")
    
    #意味を複数とってくる
    goos = driver.find_elements(:css,"div.contents-wrap-b ol.list-meanings > .in-ttl-b")
    
    #品詞をテキストにして配列に
    gooHinshi_s.each do |gooHinshi|
        @gooSpeeches.push(gooHinshi.find_element(:tag_name,'span').text)
    end
    
    
    #意味をテキストにして配列に
    goos.each do |meaning|
        @gooMeanings1.push(meaning.text)
    end
    
    #それをインデックスと意味に分割 
    @gooMeanings1.each do |meaning|
        strAry = meaning.split(" ", 2)
        @gooNumbers.push(strAry[0])
        @gooMeanings.push(strAry[1])
    end
   
   #######enHack############## 
    
    # #enHack辞書にアクセスする
    # driver.get("https://enhack.app/dic/")
    
    # if driver.find_elements(:class,'searchbar-input').size >= 1 then
    #     #検索テキストボックスの要素をid属性値から取得
    #     element = driver.find_element(:class,'searchbar-input')
    #     element = element.find_element(:tag_name,'input')
    #     #検索テキストボックスに"Selenium"を入力し検索を実行
    #     element.send_keys(@word, :enter)
    # end
    
    # sleep 1
     
    
    # ###enHack辞書####
    # speeches = driver.find_elements(:css,'div.wordnet-item-headr')#単語が持つ品詞の数、名詞と動詞なら2
    # #品詞をテキストにして配列に
    # speeches.each do |speech|
    #     @enHackSpeeches.push(speech.text)
    # end
    
    # # puts @enHackSpeeches
    
    # #各意味の前につく番号
    # numbers = driver.find_elements(:css,'div.wordnet-item span.wordnet-item-def-number')
    # #テキストにして配列に
    # numbers.each do |number|
    #     @enHackNumbers.push(number.text)
    # end
    
    # # puts @enHackNumbers
    
    # #enHackから語彙の意味だけ取ってくる
    # enHacks = driver.find_elements(:css,'div.wordnet-item-def span.sentence-placeholder')
    # #文字にして配列にする
    # enHacks.each do |enHack|
    #     @enHackMeanings.push(enHack.text)
    # end
    
    # # puts @enHackMeanings
    
    # #enHackから語彙の意味だけ取ってくる
    # enhackJPs = driver.find_elements(:css,'div.wordnet-item-def div.card-content-jp')
    # #文字にして配列にする
    # enhackJPs.each do |enHack|
    #     @enHackJPs.push(enHack.text)
    # end
    
    driver.quit # ブラウザ終了
    
    erb :index
    
end

post '/save' do #サインインのデータを受け取りパスワード正しいか認証
    Word.create(
        user_id: current_user.id,
        word: params[:searchWord],
        meaning: params[:meaning],
        important: false,
    )
    redirect '/home'
end

post '/:word_id/delete' do #投稿削除機能
    word = Word.find(params[:word_id])
    word.destroy
    redirect '/home'
end

post '/:word_id/important' do
    word = Word.find(params[:word_id])
    word.important = !word.important
    word.save
    redirect "/home"
end