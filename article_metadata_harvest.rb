class ArticleMetadataHarvest
  require 'bundler/setup'
  require 'axlsx'
  require 'byebug'
  require_relative 'article_result_page'

  attr_accessor :count, :current_page, :number_of_pages, :page, :worksheet, :workbook, :p

  def initialize(page = 1, count = 200)
    @p = Axlsx::Package.new
    @workbook = start_workbook
    @worksheet = start_worksheet
    add_header
    @count = set_count(count)
    @current_page = page
    @page = ArticleResultPage.new(start_number, count).page
  end

  def next_page
    @current_page += 1
    @page = ArticleResultPage.new(start_number, count).page
  end

  def write_page
    @page["entry"].each do |result|
      add_row(result)
    end 
  end

  def end_workbook
    @p.serialize('science_direct_harvest.xlsx')
  end

  private

  def start_workbook
    @p.workbook
  end

  def start_worksheet
    @workbook.add_worksheet(name: "data")
  end

  def add_header
    @worksheet << column_keys
  end

  def add_row(result)
    @worksheet << column_keys.collect do |key|
      column_mapping_value(key).call(result)
    end
  end

  def column_keys
    column_mapping.each.collect { |field| field.keys[0] }
  end

  def column_mapping_value(field_name)
    column_mapping.each do |field|
      return field.values[0] if field.keys.include?(field_name)
    end
  end

  def column_mapping
    [
      { title: lambda { |result| result["dc:title"] } },
      { authors: lambda do |result|
        result["authors"]["author"].collect do |author|
          "#{author["surname"]}, #{author["given-name"]}"
        end.join(";")
      end },
      { publication_name: lambda { |result| result["prism:publicationName"] } },
      { publication_type: lambda { |result| result["pubType"] } },
      { issn: lambda { |result| result["prism:issn"] } },
      { cover_date: lambda { |result| result["prism:coverDate"][0]["$"] } },
      { oa: lambda { |result| result["openaccess"] } },
      { oa_article: lambda { |result| result["openaccessArticle"] } },
      { oa_license: lambda { |result| result["openaccessUserLicense"] } },
      { link: lambda do |result|
          result["link"].each do |l|
            return l["@href"] if l["@ref"] == "scidir"
          end
      end },
      { doi: lambda { |result| result["dc:identifier"] } }

    ]
  end

  def set_count(count)
    count.to_s
  end

  def start_number
    # if count is 200, for page one: 0, for page two: 200
    (@current_page - 1) * @count.to_i
  end

  def get_page

  end

  def number_of_pages

  end
end
