# coding: utf-8
# require 'json'
require 'httpclient'
require 'kconv'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader' if development?
require 'active_record'
require './model.rb'

# require './models/opendatas.rb'

class Opendatas < ActiveRecord::Base
end


class Impdata

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
  @save_data = []
  @record = {}
  for clm in csv_data do
    clm.delete!("\"")
    if row_count==20 then
      clm.each_line do |line|
        line.strip!
        line.slice!("\"")
        # puts line
        if row_count==20 then
          @record[:url] = line
          @save_data.push(@record)
          # puts "===end==="
          row_count = -1
          @record = {}
        else
          @record[:openid] = line
          row_count = row_count+1
        end
      end
    else
      case row_count
      # when 0 then
      #   @record[:openid] = clm
      when 1 then
        @record[:latitude] = clm
      when 2 then
        @record[:longitude] = clm
      when 9 then
        @record[:name] = clm
      when 10 then
        @record[:desc] = clm
      when 13 then
        @record[:tel] = clm
      end
      # puts clm
    end
    # puts row_count
    row_count = row_count+1
  end

  for save_row in @save_data do

    odata = Opendatas.find_by(open_id: save_row[:openid])

    if odata == nil
      odata = Opendatas.new
    end

    odata.latitude = save_row[:latitude]
    odata.longitude = save_row[:longitude]
    odata.name = save_row[:name]
    odata.desc = save_row[:desc]
    odata.tel = save_row[:tel]
    odata.url = save_row[:url]

    odata.save

  end
end
