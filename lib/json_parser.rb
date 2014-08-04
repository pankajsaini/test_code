module JsonParser
  def self.response_parse(data)
    response_hash = Hash.new
    code =  data.response.code.to_i
    msg =  data.response.msg
    body =  JSON.parse data.response.body
    response_hash["status"] = code
    case code
      when 200
        response_hash["result"] = body
      else
        response_hash["message"] = msg
        response_hash["error"] = body["error"]
    end
    return response_hash
  end


  #for json parse for ticket
  def self.parse_tickets(json)
    ticket_lists  = []
    unless json.blank?
      if !json['result']['tickets'].blank? and json['result']['tickets'].length >= 0
        json['result']['tickets'].each_with_index do |page, index|
          ticket_lists << { :subject => page['subject'],
                            :description => page['description'],
                            :request_date => DateTime.strptime(page['created_at'],'%Y-%m-%dT%H:%M:%S%z') ,
                            :status => page['status'],
                            :close_date => DateTime.strptime(page['updated_at'],'%Y-%m-%dT%H:%M:%S%z'),
                            :rating_score => page['satisfaction_rating']["score"]
          }
        end
      end
    end
    return ticket_lists
  end

  #data parser for user details  entries object
  def self.data_parse_for_email(json)
    company_data  = nil
    if json
      data = []
      entries = json['entries']
      entries_length = json['entries'].length
      if entries && entries_length >= 0
        entries.each_with_index do |page, index|
          email = page['email']
          if email
            data << email
          end
        end
        company_data = data
      end
    end
    return company_data
  end

end