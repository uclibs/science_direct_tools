require "bundler/setup"
require_relative "article_metadata_harvest"

START_YEAR = "2013"

def collect_year
  @harvest.number_of_pages.times do |page|
    puts "#{@harvest.year} - #{@harvest.current_page}" 
    @harvest.write_page
    @harvest.next_page
  end 
  @harvest.next_year
end

@harvest = ArticleMetadataHarvest.new(START_YEAR)
@harvest.end_workbook
