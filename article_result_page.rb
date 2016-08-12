class ArticleResultPage
  require "net/http"
  require "uri"
  require "yaml"
  require "json"

  SEARCH_TYPE = "science_direct_search"
  RESULT_TYPE = "application/json"

  attr_accessor :page

  def initialize(start_number = 0, count = 200) #the max count is 200
    @page = JSON.parse(search(start_number.to_s, count.to_s).response.body)["search-results"]
  end

  #private

  def search(start_number, count)
    Net::HTTP.get_response(uri(start_number, count))
  end

  def uri(start_number, count)
    URI.parse(search_config["uri"] + "?" +
              "query=" + search_query + "&" +
              "start=" + start_number + "&" +
              "count=" + count + "&" +
              "apiKey=" + api_key)
  end

  def api_key
    api_config["api_key"]
  end

  def search_query
    search_config["query"].keys.map do |field|
      "#{field}(#{search_config["query"][field]})"
    end.join(" and ")
  end

  def api_config
    @api_config||= YAML.load(
      File.read("api_config.yml")
    )
  end

  def search_config
    @search_config||= YAML.load(
      File.read("search_config.yml")
    )[SEARCH_TYPE]
  end
end
