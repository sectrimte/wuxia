require 'rss'
require 'pstore'

class Parse_RSS
  def initialize(url="http://www.wuxiaworld.com/feed/")
    @works = [:ATG, :COL, :HJC, :TDG, :ISSTH]
    
    @url = url
    @rss = RSS::Parser.parse(@url, false)
    #init hashes
    @titles = Hash.new
    @links = Hash.new
    
    @works.each do |work|
      @titles[work] = Array.new
      @links[work] = Array.new
    end
    
  end

  #parse work's titles and links into instance vars
  def searchTitle(work)
    titles = Array.new
    links = Array.new
    @rss.items.each do |item|
      if item.title.include? work
        titles.push(item.title)
        links.push(item.link)
      end
    end    
    @titles[work.to_sym], @links[work.to_sym] = titles.reverse, links.reverse
  end
  
  #store instance vars into a pstore file
  def storeAllTitles
    @works.each do |work|
      searchTitle(work.to_s)
      #puts @titles[work]
    end
    
    wuxia_data = PStore.new('wuxia.pstore')
    wuxia_data.transaction do
      wuxia_data[:titles] = @titles
      wuxia_data[:links] = @links
      wuxia_data.commit
    end
  end
  
  
end

parser = Parse_RSS.new
parser.storeAllTitles

=begin
parser = Parse_RSS.new
parser.storeAllTitles
=end
