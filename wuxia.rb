require_relative 'gen_epub'
require_relative 'envoi_mail'
require 'pstore'

class Wuxia
  def initialize
    @@works = [:ATG, :COL, :HJC, :TDG, :ISSTH]
    @@mail_user = ['kedeomas@gmail.com', 'phu.boris@gmail.com', 'davidc2509@gmail.com']
    
    @wuxia_data = PStore.new('wuxia.pstore')
    @postedWorks = @wuxia_data.transaction{ @wuxia_data.fetch(:postedWorks, {} ) }
    #create work's array
    @@works.each do |work|
      if @postedWorks[work].nil?
        @postedWorks[work] = Array.new
        puts "created #{work.to_s} posted work"
      end
    end
    @wuxia_data.transaction do
      @wuxia_data[:postedWorks] = @postedWorks
      @wuxia_data.commit
    end
    
  end
  
  def get_release_url(url)
    page = open(url).read
    #get div entry-content's content
	begin
      result = page.match(/<div class="entry-content">(.*?)<\/div>/im)[1]
	rescue
	  return []
	end
    result = result.scan(/href="(.*?)"/im).flatten
	#test if there is a chapter link in the post
    if not result.join.include?'index'
	  #if not retry extracting links in first link
      result = get_release_url(result[0])
    end
    if result.join.include?'index'
      return result
	else
	  return []
    end
  end
  
  
  def extract_url_tail(url)
	if url[-1] != '/'
	  url = url + '/'
	end
    tail = url.match(/.*\/(.*?)\/$/)
    return tail[1]
  end
  
  def generate(work)
    puts "searching for #{work.to_s} release"
    
    #get titles and links parsed
    if @@works.include? work
      titles = @wuxia_data.transaction { @wuxia_data.fetch(:titles, {} ) }
      links = @wuxia_data.transaction { @wuxia_data.fetch(:links, {} ) }
      links = links[work]
    end
    puts titles
    if titles.any?
      links.each do |link|
        urls = get_release_url(link)
        urls.each do |url|
          #update postedWorks
          @postedWorks = @wuxia_data.transaction{ @wuxia_data.fetch(:postedWorks, {} ) }
          
          
          tail = extract_url_tail(url)
		  #puts "tail #{tail}"
          next if not (tail.include? 'book' or tail.include? 'chapter' or tail.include? 'volume' )          
          puts "extract tail from url #{url} => #{tail}"
          #test if chapter has already been processed
          puts @postedWorks
          if not @postedWorks[work].include? tail
            gen = GenWuxiaEpub.new
            puts "creating epub named #{tail}"
            epub_name = gen.generate_epub_from(tail, url)
            mail_file = File.basename(epub_name)
            
            sendMail(tail, mail_file)
            
            #add done chapter to pstore
            @postedWorks[work].push(tail)
            @wuxia_data.transaction do
              @wuxia_data[:postedWorks] = @postedWorks
              @wuxia_data.commit
            end
          end
        
        end #end each url in a post (link)
      end #end each link
    end #end titles have been parsed
  end
  
  def sendMail(name, mail_file)
    begin
    send_mail = MailAttached.new(name, mail_file)          
    @@mail_user.each do |email|
      send_mail.sendMail(email)
    end
    ensure
      send_mail.logout
    end
  end
  
  def generateAll
    @@works.each do |work|
      generate(work)
    end
  end
end

puts Time.now
wuxia = Wuxia.new
wuxia.generateAll
