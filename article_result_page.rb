class ArticleResultPage
  require "net/http"
  require "uri"
  require "yaml"
  require "json"

  SEARCH_TYPE = "science_direct_search"
  RESULT_TYPE = "application/json"

  attr_accessor :page, :start_number, :count, :year

  def initialize(start_number = 0, count = 200, year) #the max count is 200
    @start_number = start_number.to_s
    @count = count.to_s
    @year = year.to_s
    @page = JSON.parse(search.response.body)["search-results"]
  end

  #private

  def search
    Net::HTTP.get_response(uri)
  end

  def uri
    URI.parse(search_config["host"] +
              search_config["path"] + "?" +
              "query=" + search_query + "&" +
              "date=" + "#{self.year}" + "&" +
              "view=" + "COMPLETE" + "&" +
              "start=" + @start_number + "&" +
              "count=" + @count + "&" +
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
