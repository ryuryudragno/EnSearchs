require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'open-uri'
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

post '/auto' do
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    # options.add_argument("--disable-gpu")
    # options.add_argument("--window-size=1280x1696")
    # options.add_argument("--disable-application-cache")
    # options.add_argument("--disable-infobars")
    # options.add_argument("--no-sandbox")
    # options.add_argument("--hide-scrollbars")
    # options.add_argument("--enable-logging")
    # options.add_argument("--log-level=0")
    # options.add_argument("--single-process")
    # options.add_argument("--ignore-certificate-errors")
    # options.add_argument("--homedir=/tmp")
    driver = Selenium::WebDriver.for :chrome, options: options
    
    #Googleにアクセスする
    # driver.get("https://google.com")
    driver.navigate.to "https://ejje.weblio.jp/"
   
    # ターミナルへページタイトルを出力
    puts driver.title
    sleep 1
    puts driver.find_element(:css, "h2").text
    
    #検索テキストボックスの要素をid属性値から取得
    element = driver.find_element(:id,'searchWord')
    #検索テキストボックスに"Selenium"を入力し検索を実行
    element.send_keys('りんご', :enter)
    
    puts driver.find_element(:class,'content-explanation').text#apple
    
    #スクショ撮る
    # driver.save_screenshot("blog.png")

    driver.quit # ブラウザ終了
    
    redirect "/"
    
    # #テキストボックスの要素をname属性から取得
    # element = driver.find_element(:name, 'q')
    
    # #取得したテキストボックスの要素に"test"を入力
    # element.send_keys "test"
    
    # #実行キーの押下
    # element.submit

    # sleep 30
end