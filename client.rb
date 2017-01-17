require "twitter"
require 'pry'
require './meetup_service'
require 'figaro'
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load
 
class TwitterClient
  RESPONSE_TIMESPAN = 60 * 60 * 15 

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['consumer_key']    #or paste your values in directly, but don't upload online!
      config.consumer_secret     = ENV['consumer_secret']
      config.access_token        = ENV['access_token']
      config.access_token_secret = ENV['access_secret']
    end
  end

  def respond_to_mentions
    timeline.each do |mention|
      if asking_about_event?(mention.full_text) && recent_tweet?(mention.created_at)
        reply_with_meetup(mention)
      end
      @last_reply_id = mention.id.to_s
    end  
   puts "Finished looking at all recent tweets" 
  end

  private

  def last_reply_id 
   @last_reply_id ||= "1" 
  end
  
  def timeline
    client.mentions_timeline(timeline_options)
  end

  def asking_about_event?(tweet_text)
    event_words.any? { |w| tweet_text.downcase.include?(w) } # does their mention use our targeted words?  
  end

  def recent_tweet?(time_posted)
    time_posted + RESPONSE_TIMESPAN >= Time.now # posted in the last 15 min?
  end

  def reply_with_meetup(mention)
    event = MeetupService.new.generate_matching_event(mention.text)
    tweet_text = case event[:type]
    when :found 
      "@#{mention.user.screen_name} See you at our next #{event[:details]['name']}! #{event[:details]['link']}"
    when :next
      "@#{mention.user.screen_name} This bot couldn't help, but we would love to see you at our next event! #{event[:details]['link']}" 
    end
    if tweet_text
      client.update(tweet_text)
      puts "Replied to Tweet# #{mention.id}"
    end
  end 

  def event_words
    ["when's the", "when is", "the next", "next class", "next event", "can you tell me", "when's denhac", "when is denhac"]
  end

  def timeline_options
    {since_id: last_reply_id} 
  end
end

TwitterClient.new.respond_to_mentions
