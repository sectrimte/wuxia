require 'rss'
require 'pstore'

class Parse_RSS
  def initialize(url="http://www.wuxiaworld.com/feed/")
    @url = url
    @rss = RSS::Parser.parse(@url, false)
  end

  def searchTitle(work)
    titles = Array.new
    links = Array.new
    @rss.items.each do |item|
      if item.title.include? work
        titles.push(item.title)
        links.push(item.link)
      end
    end
    return titles.reverse,links.reverse
  end
end


parser = Parse_RSS.new
titles = { "CD" => [], "ATG" => [] }
links = { "CD" => [], "ATG" => [] }
titles["CD"],links["CD"] = parser.searchTitle("CD")
titles["ATG"],links["ATG"] = parser.searchTitle("ATG")
wuxia_data = PStore.new('wuxia.pstore')
wuxia_data.transaction do
  wuxia_data[:titles] = titles
  wuxia_data[:links] = links
  wuxia_data.commit
end
