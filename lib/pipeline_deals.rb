require "json_parser"
require "exception"
class PipelineDeals
  attr_accessor :person_id, :company_id, :deal_id
  def initialize(api_key)
    @api_key=api_key
    @base_uri = "https://api.pipelinedeals.com/api/v3/"
    @find_people_uri = @base_uri + "people/"
    @find_company_uri = @base_uri + "companies/"
    @find_deals_uri = @base_uri + "deals/"
  end

  def get_person_details
    json_data = HTTParty.get(build_uri(@person_id, "people"))
    JsonParser::response_parse(json_data)
  end

  def get_company_details
    json_data = HTTParty.get(build_uri(@company_id, "company"))
    JsonParser::response_parse(json_data)
  end

  def get_deal_details
    json_data = HTTParty.get(build_uri(@deal_id, "deals"))
    JsonParser::response_parse(json_data)
  end

  def get_associated_people(json)
    JsonParser::data_parse_for_email(json)
  end

  private

  #Build the appropriate URL
  def build_uri(id, type)
    case type
      when "people"
        built_uri = @find_people_uri + "#{id}.json?"
      when "company"
        built_uri = @find_company_uri + "#{id}/people.json?"
      when "deals"
        built_uri = @find_deals_uri + "#{id}/people.json?"
    end

    built_uri = built_uri + "api_key=" + @api_key
    return built_uri
  end
end