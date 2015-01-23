require 'json'
require 'httpclient'
require 'kconv'
# require './models/opendata.rb'

class Opendata

  hClient= HTTPClient.new
  endpoint_uri = 'http://www4.city.kanazawa.lg.jp/data/open/cnt/3/20762/1/01kankou.csv'
  tmp_data = hClient.get_content(endpoint_uri, "content-type" => "text/csv")
  tmp_data = tmp_data.kconv(Kconv::UTF8, Kconv::UTF16)

  # ===========
  # "ID"
  # "緯度"
  # "経度"
  # "ジャンル1"
  # "サブジャンル1"
  # "ジャンル2"
  # "サブジャンル2"
  # "ジャンル3"
  # "サブジャンル3"
  # "名称"
  # "概略"
  # "郵便番号"
  # "住所"
  # "電話番号"
  # "Fax番号"
  # "E-mail"
  # "開館時間"
  # "休館日"
  # "料金"
  # "備考"
  # "リンク"
  # ===========
  csv_data = tmp_data.split("\t")
  row_count = 0;
  for clm in csv_data do
    if row_count==20 then
      clm.each_line do |line|
        line.strip!
        puts line
        if row_count==20 then
          puts "===end==="
          row_count = -1
        else
          row_count = row_count+1
        end
      end

    else
      puts clm
    end
    puts row_count
    row_count = row_count+1
  end
end
