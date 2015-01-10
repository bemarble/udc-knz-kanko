require 'json'
require 'httpclient'
# require './models/opendata.rb'

class Opendata

  # endrequest_content = {:hoge => 'hoge', :fuga_id => ['test', 'test2', 'test3']}
  hClient= HTTPClient.new
  endpoint_uri = 'http://www4.city.kanazawa.lg.jp/data/open/cnt/3/20762/1/01kankou.csv'
  # content_json = request_content.to_json
  # http_client.set_auth(endpoint_uri)
  #
  tmp_data = hClient.get_content(endpoint_uri, "content-type" => "text/csv")
  # tmp_data = tmp_data.force_encoding('UTF-8')
  # tmp_data.encode("UTF-16BE", "UTF-8",
  #   invalid: :replace,
  #   undef: :replace,
  #   replace: '.').encode("UTF-8")

  # tmp_data.encode("UTF-8")

  # 改行
  csv_data = tmp_data.split("\n")
  # connection = Mysql::connect("localhost", "udc-kana", "udc-kana", "udc-kana")
  # connection.query("set character set utf8")
  # rs = connection.query("SELECT * FROM users")
  #
  # rs.each do |r|
  #   puts r.join ", "
  # end
  #
  # connection.close

  for row in csv_data do
    # i = i+1
    # puts i
    # puts row
    row_data = row.split("\t")
    for clm in row_data do
      # puts clm
      puts clm.encode("UTF-16BE", "UTF-8",
        invalid: :replace,
        undef: :replace,
        replace: '.').encode("UTF-8")
    end
  end

end
