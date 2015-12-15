require 'gmail'

class MailAttached
  def initialize( subject, filename, msg="envoye par ruby")
    puts 'creating mailAttached'
    @subject = subject
    @msg = msg
    @filename = filename
    @gmail = Gmail.connect('sectrimte', 'password')


op


up)
  end
  
  def sendMail(dest_mail)
    filename = @filename
    subject = @subject
    msg = @msg
    


    email = @gmail.compose do
      to dest_mail
      subject subject
      body msg
      add_file filename
    end
    email.deliver! # or: gmail.deliver(email)
    puts "#{filename} sent to #{dest_mail}"

    
  end
  
  def logout
    if @gmail.logged_in?
      @gmail.logout
    end
  end
end

#send_mail = MailAttached.new("CDb21c12", "book-21-chapter-12.epub")
#send_mail.sendMail("davyphu@gmail.com")
#send_mail.sendMail("kedeomas@gmail.com")
#send_mail.logout