class Tipbot
  include Commands

  def initialize
    $client = Slack::RealTime::Client.new
  end

  def run
    $client.on :hello do
      puts "Successfully connected, welcome '#{$client.self['name']}' to the '#{$client.team['name']}' team at https://#{$client.team['domain']}.slack.com."
      populate_user_list
    end

    $client.on :reaction_added do |data|
      puts data
      reaction_added(data)
    end

    $client.on :message do |data|
      puts data
      next if data['text'].nil?
      # next if data['reply_to']
      next if data['user'] == tipbot_user_id # don't talk to yourself!
      next if data['edited'] # ignore edits
      # we only want to interact if we are in a Direct Message chat (where the user doens't have to use @tipbot)
      # OR if we are in any group chat and the person starts the message with @tipbot ...
      # channel IDs seem to be prefixed with D for direct message, C for channel?, or G for private group (although I can't find any documentation on this)
      if data['channel'][0] == 'D'
        # direct message ok to proceed
      elsif data['text'] =~ /^<@/ && data['text'] =~ /^<@#{tipbot_user_id}/
        # user prefixed message with @tipbot
      elsif data['text'] =~ /^tip /
        # prefixed with 'tip'
      else
        # message we can ignore
        next
      end

      # strip the leading @tipbot data off the front if it is there
      data['text'] = data['text'].split[1..-1].join(' ') if data['text'] =~ /^<@#{tipbot_user_id}/

      r = case data['text'].split[0]
      when 'tip'
        transfer(data)
      when 'balance', 'bal'
        balance(data)
      when 'deposit'
        deposit(data)
      when 'send', 'withdraw'
        send(data)
      when 'help', '?'
        help(data)
      when 'rank', 'leaderboard'
        rank(data)
      when 'hi'
        message(channel: data['channel'], text: "Hi <@#{data['user']}>!")
      when 'fail'
        blah # throw exception, test how gracefully it handles errors
      else
        message(channel: data['channel'], text: "Sorry <@#{data['user']}>, I didn't understand that command. Try @tipbot help.")
      end
    end

    $client.start!
  end

  def populate_user_list
    Thread.new do
      begin
        users = {}
        $client.web_client.get('/api/users.list')['members'].each do |m|
          users[m['id']] = m['name']
          $redis.set('tipbot_user_id', m['id']) if m['name'] == 'tipbot'
        end
        $redis.mapped_hmset 'users', users
      rescue Exception => e
        STDERR.puts "ERROR: #{e}"
        STDERR.puts e.backtrace
        raise e
      end
    end
  end
end
