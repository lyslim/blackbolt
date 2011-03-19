# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def date_range(start_date, end_date, between='&nbsp;〜&nbsp;')
    logger.debug start_date.class.inspect
    t = Date.today
    s = start_date.class == Date ? start_date : Date.parse(start_date)
    e = end_date.class == Date   ? end_date   : Date.parse(end_date)
    if t.year == s.year
      if   s.year == e.year then range = ['%m/%d', '%m/%d']
      else range = ['%m/%d', '%Y/%m/%d']
      end
    elsif s.year == e.year
      range = ['%Y/%m/%d', '%m/%d']
    else
      range = ['%Y/%m/%d', '%Y/%m/%d']
    end
    start_format, end_format = range
    str = s.strftime(start_format) + between + e.strftime(end_format)
    str
  end

  def app_localized_message(msg_kbn, msg_code)
    if @app_messages_hash[msg_kbn.to_s + "_" + msg_code.to_s].nil?
      return ""
    else
      return @app_messages_hash[msg_kbn.to_s + "_" + msg_code.to_s]['msg']
    end
  end

  def icon_link_tag(image, options={}, html_options={})
    alt_str = "" ;
    unless (html_options[:alt].blank?)
      alt_str = html_options[:alt]
    end
    tags = image_tag(image, {:border => 0, :align => 'absmiddle', :alt => alt_str})
    link_to(tags, options, html_options)
  end

  def select_for_codes(variable, attribute, codes, options = {}, html_options = {})
    choices = Array.new
    codes.each do | code |
      key = app_localized_message( :label, attribute.to_s + "_" + code.to_s )
      choices.push( [ key, code ] )
    end

    select( variable, attribute, choices, options, html_options )
  end

  def fmt_time(time, format)

    return '&nbsp;' if time.nil?

    case format
    when :HM
      time.strftime('%H:%M')
    when :Y2MD
      if Time.now.year == time.year
        time.strftime('%m/%d')
      else
        time.strftime('%y/%m/%d')
      end
    else
      '&nbsp;'
    end
  end

  def page_label(msg_kbn, msg_code, options = {})
    options_str = ""
    options.each_pair do |k, v|
      options_str += ' ' + k.to_s + '="' + v.to_s + '"'
    end
    return '<span '+ options_str +'>' + app_localized_message(msg_kbn, msg_code) + '</span>&nbsp;'
  end

end
