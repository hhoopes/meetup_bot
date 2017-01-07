require "twitter"
require 'pry'
require 'figaro'
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load
 
class TwitterClient
  attr_reader :last_reply_id
  RESPONSE_TIMESPAN = 60 * 60 * 24

  def initialize
   @last_reply_id = "1" 
  end

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['consumer_key']    #or paste your values in directly, but don't upload online!
      config.consumer_secret     = ENV['consumer_secret']
      config.access_token        = ENV['access_token']
      config.access_token_secret = ENV['access_secret']
    end
  end

  def respond_to_mentions
    timeline = client.mentions_timeline(timeline_options)
    timeline.each do |mention|
      if asking_about_event?(mention.full_text) && recent_tweet?(mention.created_at)
        puts "hit here"
        reply_with_meetup(mention)
      end
      @last_reply_id = mention.id.to_s
    end  
   puts "Finished looking at all recent tweets" 
  end

  private

  def asking_about_event?(tweet_text)
    event_words.any? { |w| tweet_text.downcase.include?(w) } # does their mention use our targeted words?  
  end

  def recent_tweet?(time_posted)
    time_posted - RESPONSE_TIMESPAN < Time.now # posted in the last 15 min?
  end

  def reply_with_meetup(mention)
    puts "Replied to Tweet# #{mention.id}"
  end 

  def event_words
    ["lynx","delighted!","when's the", "when is", "the next", "next class", "next event", "can you tell me", "when's denhac", "when is denhac"]
  end

  def timeline_options
    {since_id: last_reply_id} 
  end
end

TwitterClient.new.respond_to_mentions
