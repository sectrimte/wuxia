# wuxia
- parse wuxiaworld's rss into a pstore file
- search in pstore file for new chapter
- convert new chapter to epub format
- mail epub through gmail

####required gems :
- gepub
- gmail

####setup:

change login in envoi_mail.rb line 9
```
@gmail = Gmail.connect('sectrimte', 'password')
```

####usage:

######rss_parse.rb

create parser object (titles are to be added in @works variable)
```
parser = Parse_RSS.new
parser.storeAllTitles
```

######wuxia.rb
create wuxia object that searches, converts, sends (titles are to be added in @works variable)
```
wuxia = Wuxia.new
wuxia.generateAll
```

#####lancer.bat
use lancer.bat to run the scripts on windows

planned task is the way to go
