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

  #api for find person by email
  def get_person_by_email
    json_data = HTTParty.get(build_uri(@person_email, "email"), :headers => {"Authorization" => "#{@token_type} #{@access_token}"})
    JsonParser::response_parse(json_data)
  end

  #api for getting all tickets
  def get_tickets_by_api
    json_data = HTTParty.get(build_uri(@user_id, "tickets"), :headers => {"Authorization" => "#{@token_type} #{@access_token}"})
    return JsonParser::parse_tickets(JsonParser::response_parse(json_data))
  end

  def get_person_tickets(person_obj,response)
    if person_obj["status"] == 200
      unless person_obj["result"]["results"].blank?
        zendesk_user_id = person_obj["result"]["results"][0]["id"]
        self.user_id = zendesk_user_id
        tickets = self.get_tickets_by_api
        response["tickets"] = tickets
      end
    end
    return response
  end


  def get_all_tickets(associated_people)
    data_array = []
    associated_people.each {|email|
      self.person_email = email
      person_obj = self.get_person_by_email
      response = Hash.new
      response["email"]= email
      response["tickets"] =nil
      data_array <<  self.get_person_tickets(person_obj,response)
    }
    return data_array
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