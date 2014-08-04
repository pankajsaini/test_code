class ApplicationController < ActionController::Base
  protect_from_forgery

  def get_tickets(associated_people,zendeskApi_obj)
    data_array = []
    associated_people.each {|email|
      zendeskApi_obj.person_email = email
      person_obj = zendeskApi_obj.get_person_by_email
      response = Hash.new
      response["email"]= email
      response["tickets"] =nil
      data_array <<  zendeskApi_obj.get_person_tickets(person_obj,response)
    }
    return data_array
  end
end
