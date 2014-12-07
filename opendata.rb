require 'json'
require 'httpclient'

class Opendata

  # endrequest_content = {:hoge => 'hoge', :fuga_id => ['test', 'test2', 'test3']}
  hClient= HTTPClient.new
  endpoint_uri = 'http://www4.city.kanazawa.lg.jp/data/open/cnt/3/20762/1/01kankou.csv'
  # content_json = request_content.to_json
  # http_client.set_auth(endpoint_uri)
  #
  tmp_data = hClient.get_content(endpoint_uri, "content-type" => "text/csv")
  # tmp_data = tmp_data.force_encoding('UTF-8')
  tmp_data.encode("UTF-16BE", "UTF-8",
    invalid: :replace,
    undef: :replace,
    replace: '.').encode("UTF-8")

  # 改行
  csv_data = tmp_data.split("\n")
  # i=0
  for row in csv_data do
    # i = i+1
    # puts i
    # puts row
  end

end
