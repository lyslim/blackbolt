module Result
  #
  # The contents of the specified parameters to generate a return JSON data
  # _success_:: processing result (true: Successful, false: failure) specified in the Boolean type
  # _message_:: specifies the message to pass data
  # _result_::  appears that the key data generated to specify the hash result information data
  #
  # Returns:: JSON Data
  #
  def result_for_json(success, message, result)
    ret = {
      :success => success,
      :message => message,
      :result  => result
    }
    return ret.to_json
  end

end
