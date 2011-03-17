
module Messages

  ###########################################################
  # method：loadMessage
  # abstract: data table for localization(multi-language), which reads and stores in hash
  # arguments: none
  # returns: none
  ###########################################################
  def loadMessage
    # determination of the column to be retrieved
    lang  = 'en'
    langs = [:en, :cn]
    lang  = langs.include?(lang.intern) ? lang : 'base'
    
    select     = " id,msg_code,msg_kbn,msg_#{lang.to_s} as msg "
    conditions = " valid_flg = 1 "
    # search
    opt = {
      :select     => select,
      :conditions => conditions
    }
    @app_messages = MstMessage.find(:all, opt)

    #-----------------------------
    # categories and stores the key hash code
    #-----------------------------
    @app_messages_hash = Hash.new
    for app_message in @app_messages
      msg_kbn = case app_message.msg_kbn
                when 1 then :label   # labels
                when 2 then :confirm # confirmation message
                when 3 then :error   # error mesage
                else        :other   # other
                end
      # hash stores for localization
      @app_messages_hash[msg_kbn.to_s + "_" + app_message.msg_code] = app_message.attributes
    end
  end

end
