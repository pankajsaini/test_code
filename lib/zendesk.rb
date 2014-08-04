require "json_parser"
class Zendesk
  attr_accessor :person_email , :user_id
  def initialize(subdomain,access_token,token_type)
    @subdomain=subdomain
    @access_token=access_token
    @token_type = token_type
    @base_uri = "https://#{@subdomain}.zendesk.com/api/v2/"
    @find_people_uri = @base_uri + "search.json?query=type:user+email:"
    @find_tickets_uri = @base_uri + "users/"
  end

  def get_person_by_email
    json_data = HTTParty.get(build_uri(@person_email, "email"), :headers => {"Authorization" => "#{@token_type} #{@access_token}"})
    JsonParser::response_parse(json_data)
  end

  def get_tickets
    json_data = HTTParty.get(build_uri(@user_id, "tickets"), :headers => {"Authorization" => "#{@token_type} #{@access_token}"})
    data = JsonParser::response_parse(json_data)
    return JsonParser::parse_tickets(data)
  end


  def get_person_tickets(person_obj,response)
    if person_obj["status"] == 200
      unless person_obj["result"]["results"].blank?
        zendesk_user_id = person_obj["result"]["results"][0]["id"]
        self.user_id = zendesk_user_id
        tickets = self.get_tickets
        response["tickets"] = tickets
      end
    end
   return response
  end

  private

  #Build the appropriate URL
  def build_uri(value, type)
    case type
      when "email"
        built_uri = @find_people_uri+ value
      when "tickets"
        built_uri = @find_tickets_uri + "#{value}/tickets/requested.json"
    end
    return built_uri
  end
end