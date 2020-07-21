require 'net/http' #標準ライブラリの呼び出し
require 'uri'
require 'json' #jsonを使うためのライブラリ
require 'nokogiri'
require 'open-uri'
# linebot-sdkを扱うために以下２つを読み込み
require 'sinatra'
require 'line/bot'

# userから駅名を受け取る
# station_name = gets.chomp
station_name = "赤坂"
# 駅名を駅コードに変換
station_code = {
:代々木上原 => "23044",
:代々木公園 => "23045",
:明治神宮前 => "23016",
:表参道  => "22588",
:乃木坂 => "22893",
:赤坂 => "22485",
:国会議事堂 => "22668",
:霞が関 => "22596",
:日比谷 => "22951",
:二重橋前 => "22883",
:大手町 => "22564",
:新御茶ノ水 => "22732",
:湯島 => "23038",
:根津 => "22888",
:千駄木 => "22782",
:西日暮里 => "22880",
:町屋 => "22978",
:北千住 => "22630",
:綾瀬 => "22499",
:北綾瀬 => "22627"
}

# 到着駅を綾瀬に固定してリクエストを投げる　
res1 = Net::HTTP.get(URI.parse("http://api.ekispert.jp/v1/json/search/course/light?key=LE_fHM9TSpsph9Cu&from=#{station_code[station_name.to_sym]}&to=22499"))

#叩いて返ってきたJSONをhashに格納
hash = JSON.parse(res1)

url = hash["ResultSet"]["ResourceURI"]

#返ってくるresのurlからスクレイピングして必要な部分のhtmlを抜き出して時間を出力
charset = nil

html = URI.open(url) do |f|
  charset = f.charset
  f.read
end

# スクレイピングして取ってきたテキストをxに格納
doc = Nokogiri::HTML.parse(html, nil, charset)
doc.xpath('/html/body/div[1]/div[4]/div/div[1]/div[1]/h1').each do |node|
  x = node.inner_text
  puts x
end

# line-bot-sdkから引っ張ってきたコード
# やりたいこと->xをメッセージとして出力する

def handler(event:, context:)
  body = event["body"]
  signature = event["headers"]["X-Line-Signature"]
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end
  requests = client.parse_events_from(body)
    equests.each do |req|
    case req
    when Line::Bot::Event::Message
      case req.type
      when Line::Bot::Event::MessageType::Text
        mes = req.message['text']
        token = req['replyToken']
        message = {
          type: 'text',
          text: mes
        }
        client.reply_message(token, message)
      end
    end
  end
end

private 

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV['LINE_CHANNEL_SECRET']
    config.channel_token = ENV['LINE_CHANNEL_TOKEN']
  }
end
