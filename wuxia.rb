require_relative 'gen_epub'
require_relative 'envoi_mail'
require 'pstore'

class Wuxia
  def initialize
    @@works = [:CD, :ATG]
    @@mail_user = ['kedeomas@gmail.com', 'phu.boris@gmail.com']
    
    @wuxia_data = PStore.new('wuxia.pstore')
    @cd_last_book = @wuxia_data.transaction { @wuxia_data.fetch(:cd_last_book, 0) }
    @cd_last_chapter = @wuxia_data.transaction { @wuxia_data.fetch(:cd_last_chapter, 0) }
    @atg_last_chapter = @wuxia_data.transaction { @wuxia_data.fetch(:atg_last_chapter, 0) }
    
    puts "--------------------------------------------"
    puts "last CD : book #{@cd_last_book} chapter #{@cd_last_chapter}"
    puts "last ATG : chapter #{@atg_last_chapter}"
  end
  
  def get_release_url(url)
    page = open(url).read
    #get div entry-content's content
    result = page.match(/<div class="entry-content">(.*?)<\/div>/im)[1]    
    result = result.scan(/href="(.*?)"/im).flatten
    return result
  end
  
  def extract_CD_url(url)
    match = url.match(/book-(\d+)-chapter-(\d+)/)
	if match.size == 3
      return match[1].to_i, match[2].to_i
	end
  end
  
  def extract_ATG_url(url)
    chapter = url.match(/chapter-(\d+)/)
    if chapter.nil?
	  return 0
    else
      return chapter[1].to_i
	end
  end
    
  def generate_and_send(work)
    puts "searching for #{work} release"
    if @@works.include? work.to_sym
      titles = @wuxia_data.transaction { @wuxia_data.fetch(:titles, {} ) }
      links = @wuxia_data.transaction { @wuxia_data.fetch(:links, {} ) }
      links = links[work]
	  #puts links
    end
    if titles.any?
      if (work.casecmp "CD") == 0
        links.each do |link|
          urls = get_release_url(link)
          urls.each do |url|
            book,chapter = extract_CD_url(url)
            if (@cd_last_book < book) or (@cd_last_book == book and @cd_last_chapter < chapter)
			  puts url
              gen = GenWuxiaEpub.new
              epub_name, url_tail = gen.generate_epub_from(work, url)
              mail_file = File.basename(epub_name)
              
              begin
                send_mail = MailAttached.new(url_tail, mail_file)          
                @@mail_user.each do |email|
                  send_mail.sendMail(email)
                end
              ensure
                send_mail.logout
              end
              
              
              @wuxia_data.transaction do
                @wuxia_data[:cd_last_book] = book
                @wuxia_data[:cd_last_chapter] = chapter
                @wuxia_data.commit
              end
              @cd_last_book, @cd_last_chapter = book, chapter
            end
          end
        end
      end
      if (work.casecmp "ATG") == 0
        links.each do |link|
          urls = get_release_url(link)
          urls.each do |url|
            chapter = extract_ATG_url(url)
            if (@atg_last_chapter < chapter)
			  puts url
              gen = GenWuxiaEpub.new
              epub_name, url_tail = gen.generate_epub_from(work, url)
              mail_file = File.basename(epub_name)
              
              begin
                send_mail = MailAttached.new(url_tail, mail_file)          
                @@mail_user.each do |email|
                  send_mail.sendMail(email)
                end
              ensure
                send_mail.logout
              end
              
              
              @wuxia_data.transaction do
                @wuxia_data[:atg_last_chapter] = chapter
                @wuxia_data.commit
              end
              @atg_last_chapter = chapter
            end
          end
        end
      end #end ATG   
    end #rss found
  end
  

end

wuxia = Wuxia.new
puts Time.now
wuxia.generate_and_send("ATG")
wuxia.generate_and_send("CD")


