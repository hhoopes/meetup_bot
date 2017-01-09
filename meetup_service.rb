require 'pry'
require 'figaro'
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load
require 'meetup_client'

class MeetupService
  def self.client

  end 

  def generate_response(mention)
    
  end
end
