@echo off

if not exist log_wuxia.txt (
  echo. >log_wuxia.txt
)
ruby rss_parse.rb >> log_wuxia.txt
ruby wuxia.rb >> log_wuxia.txt