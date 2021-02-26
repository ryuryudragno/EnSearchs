require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'open-uri'
require 'net/http'
require 'json'
require 'nokogiri'
require 'selenium-webdriver'

require 'sinatra/activerecord'

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

get '/search' do
    @word = params[:searchWord]#検索語
    @gooMeanings= []
    @enHackMeanings= []
    
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    driver = Selenium::WebDriver.for :chrome, options: options
    
    #goo辞書にアクセスする
    driver.get("https://dictionary.goo.ne.jp/word/en/#{@word}")
   
    # ターミナルへページタイトルを出力
    puts driver.title
    
    #意味を複数とってくる
    goos = driver.find_elements(:css,"div.contents-wrap-b ol.list-meanings > .in-ttl-b")
    #ここからサーバー側で処理する必要がある
    goos.each do |meaning|
        @gooMeanings.push(meaning.text)
    end
    # length = @meanings.size
    # @maji = @meanings[a-2].text
    
    
    #goo辞書にアクセスする
    driver.get("https://enhack.app/dic/")
    
    #検索テキストボックスの要素をid属性値から取得
    element = driver.find_element(:class,'searchbar-input')
    element = element.find_element(:tag_name,'input')
    #検索テキストボックスに"Selenium"を入力し検索を実行
    element.send_keys(@word, :enter)
    
    # enHacks = driver.find_elements(:class,'sentence-placeholder')
    enHacks = driver.find_elements(:css,'span.sentence-placeholder')
    #ここからサーバー側で処理する必要がある
    enHacks.each do |enHack|
        
        @enHackMeanings.push(enHack.text)
    end
    

    driver.quit # ブラウザ終了
    
    erb :index
    
    
    # #実行キーの押下
    # element.submit

    # sleep 30
end