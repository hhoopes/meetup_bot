require 'httparty'

class MeetupService
  def generate_matching_event(mention)
    matching = filter_events(mention, get_events)
    matching.nil? ? {type: :next, details: get_events.first} : {type: :found, details: matching}  
  end

  def filter_events(mention, events)
    mention_text = mention.downcase.gsub(/\W/, ' ')
    denhac_events.each do | popular_name, meetup_name |
      mention_text = meetup_name if mention_text.include?(popular_name.to_s)
    end
    events.detect do | event |
      mention_text.include? event['name'].downcase
    end
  end

  private

  def get_events
    HTTParty.get("https://api.meetup.com/denhac-hackerspace/events", query: meetup_options)
  end
  
  def denhac_events
    {
      "code night": "coding night",
      "movie night":  "hacker movie monday",
      "work from denhac": "work from denhac day",
      "work from the space": "work from denhac day",
      "lockpicking": "locksport",
      "robotics": "robotics league",
      "cosplay": "cosplay/prop making workshop",
      "laser cutter": "laser cutter training",
      "3d printer": "3d printer training",
    }
  end

  def meetup_options
    {
      "page": 40,
      "only": "name,link",
    }
  end
end

