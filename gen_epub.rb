# encoding: UTF-8
require 'open-uri'
require 'gepub'
#require_relative 'envoi_mail'

#index_page = open('http://www.wuxiaworld.com/cdindex-html/').readlines
#index_page = open('http://baishuku.com/html/29/29363/11905089.html').readlines

#index_page = open("index.html", 'r').readlines

#puts 'what is book number'
#book_number = gets.chomp

#puts 'what is chapter number'
#chapter_number = gets.chomp

class GenWuxiaEpub
  def generate_epub_from(wuxia_title, url)
    puts "url = #{url}"
    url_tail = url.match(/([^\/]+)(\/?$)/)[1]
    puts "url_tail = #{url_tail}"
    page = open(url).read
    #page = open("http://www.wuxiaworld.com/cdindex-html/book-#{book_number}-chapter-#{chapter_number}/").read
    #page = open('http://baishuku.com/html/29/29363/11905089.html').read
    #page = open('saved_page.html', 'r').read

    page = page.match(/<article(.|\n)+?<\/article>/)[0]
    page = page.gsub(/<a.+?\<\/a>/, '')
    page = '<!DOCTYPE html><html lang="en-US"><head><meta charset="UTF-8"></head><body>'+page+'</body></html>'

    #book_number = 15
    # index_page.each do |l|
    #   match = l.scan(/www[a-z.\/-]+book-#{book_number}+-chapter-\d+/)
    #   if match.size > 0
    #     page = open(match).readlines
    #   end
    # end

    saved_page = open('saved_page.html', 'w')
    saved_page.write(page)

    builder = GEPUB::Builder.new {
      language 'en'
      unique_identifier 'http:/example.jp/bookid_in_url', 'BookID', 'URL'
      title "#{wuxia_title}_#{url_tail}"
      #subtitle "book-#{book_number}-chapter-#{chapter_number}"

      creator 'sectrimte'

      # date '2012-02-29T00:00:00Z'

      resources(:workdir => '.') {
        # cover_image 'img/image1.jpg' => 'image1.jpg'
        ordered {
          # file 'text/chap1.xhtml'
          # heading 'Chapter 1'
          #
          # file 'text/chap1-1.xhtml'

          file 'saved_page.html'
          #heading 'Chapter 1'
        }
      }
    }
    epubname = File.join(File.dirname(__FILE__), "#{url_tail}.epub")
    builder.generate_epub(epubname)

    return epubname, url_tail
  end
end

#gen = GenWuxiaEpub.new
#epub_name, url_tail = gen.generate_epub_from("ATG", "http://www.wuxiaworld.com/atg-index/atg-chapter-215/")
#puts File.basename(epub_name)
#send_mail = MailAttached.new(url_tail, File.basename(epub_name))
#send_mail.sendMail("davyphu@gmail.com")
