require 'net/http' #標準ライブラリの呼び出し
require 'uri'
require 'json' #jsonを使うためのライブラリ
require 'nokogiri'
require 'open-uri'
require 'sinatra'
require 'line/bot'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = ENV['LINE_CHANNEL_ID']
    config.channel_secret = ENV['LINE_CHANNEL_SECRET']
    config.channel_token = ENV['LINE_CHANNEL_TOKEN']
  }
end

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

# 毎回実行したい処理だけブロックの中に記述
post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each do |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
         # userから送られてくるテキストを変数に格納
          @station_name = event.message["text"]
          station_name_sym = @station_name.to_sym
          # 到着駅を綾瀬に固定してリクエストを投げる
          res1 = Net::HTTP.get(URI.parse("http://api.ekispert.jp/v1/json/search/course/light?key=#{ENV['ACCESS_KEY']}&from=#{station_code[@station_name.to_sym]}&to=22499"))

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
          doc.xpath('/html/body/div[1]/div[4]/div/div[1]/div[2]/div/table/tr[1]/td[3]/p[1]').each do |node|
            $time = node.inner_text
          end
          if station_code.include?(station_name_sym)
            message = {type: 'text',text: "次の綾瀬行の電車は#{$time}です"}
          elsif
            message = {type: 'text',text: "これは千代田線の駅ではありません。別の駅を入力してください"}
            client.reply_message(event['replyToken'], message)
          end
      end
    end
  # Don't forget to return a successful response
  "OK"
  end
end

if station_code.include?(a)
  puts "これは千代田線内の駅です"
elsif
  puts "これは千代田線の駅ではありません。別の駅を入力してください"
end
