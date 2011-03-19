require 'nkf'

class Iso2022jpMailer < ActionMailer::Base
  @@default_charset = 'iso-2022-jp'
  @@encode_subject = false
  
  def base64(text, charset='iso-2022-jp', convert=true)
    if convert && charset == 'iso-2022-jp'
      text = NKF.nkf('-j -m0', text)
    end
    text = [text].pack('m').delete("\r\n")
    "=?#{charset}?B?#{text}?="
  end

  def create!(*)
    super
    @mail.body = NKF.nkf('-j', @mail.body)
    return @mail
  end
end

