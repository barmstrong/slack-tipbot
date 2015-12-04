module Commands
  def help data
    response = {
      channel: data['channel'],
      text: "Here's how I work!
```
Usage: tip @user [amount]

Tipping

  tip @bob            # send @bob 10 bits
  tip @bob 1000       # send @bob 1000 bits
  tip @bob 5 USD      # send @bob 5 U.S. dollars in bitcoin

Other Commands

  @tipbot balance                              # shows your balance, 'bal' also works
  @tipbot deposit                              # reveal a bitcoin address
  @tipbot withdraw <amount> <address|email>    # withdraw to a bitcoin address
  @tipbot send <amount> <address|email>        # same as withdraw
  @tipbot leaderboard                          # see who has got what, 'rank' also works

In direct message chat, you can issue the commands without prefixing '@tipbot ...'.
      ```".strip
    }
    message(response)
  end

  def default data
    message({channel: data['channel'], text: "I didn't recognize that command. Here is some help on usage..."})
    help(data)
  end

  def transfer data
    command, to_user, amount = data['text'].split
    return {text: "Invalid syntax. Try 'help'"} unless to_user =~ /^<@.*>/
    to_user = to_user[2..-2]
    amount ||= 10

    from_account = find_or_create_account(data['team'], data['user'])
    to_account = find_or_create_account(data['team'], to_user)

    tx = coinbase.account(from_account).transfer(to: to_account, amount: bits_to_btc(amount), currency: 'BTC')
    amount_in_bits = btc_to_bits(tx.amount.amount)
    message(channel: data['channel'], text: "Sent #{amount_in_bits} bits to <@#{to_user}>!")

    channel = direct_message_channel(to_user)
    message(channel: channel, text: "<@#{data['user']}> sent you #{amount_in_bits} bits!")
  rescue Coinbase::Wallet::APIError => e
    fail e.message, data['channel']
  end

  def balance data
    account_id = find_or_create_account(data['team'], data['user'])
    b = coinbase.account(account_id).balance
    message(channel: data['channel'], text: "You've got #{btc_to_bits(b.amount)} bits <@#{data['user']}>")
  rescue Coinbase::Wallet::APIError => e
    fail e.message, data['channel']
  end

  def deposit data
    account_id = find_or_create_account(data['team'], data['user'])
    account = coinbase.account(account_id)
    addr = account.create_address
    msg = "You can send funds to `#{addr.address}` to raise your balance <@#{data['user']}>."
    web_message({
      text: msg,
      attachments: [
        {
          fallback: msg,
          image_url: "https://chart.googleapis.com/chart?cht=qr&chs=250x250&chl=bitcoin%3A#{addr.address}"
        }
      ],
      channel: data['channel']
    })
  rescue Coinbase::Wallet::APIError => e
    fail e.message, data['channel']
  end

  def send data
    command, amount, to, currency = data['text'].split
    return {text: "Try this format: `@tipbot withdraw <amount> <bitcoin-address|email>`"} if amount.nil? or to.nil?
    currency ||= 'BTC'
    account_id = find_or_create_account(data['team'], data['user'])
    account = coinbase.account(account_id)
    if to =~ /<mailto:/
      to = to.match(/:(.*)\|/)[1] # strip email out
    end
    tx = account.send(to: to, amount: bits_to_btc(amount), currency: 'BTC')
    puts tx
    message(channel: data['channel'], text: "Sent #{amount} bits to #{to}!")
  rescue Coinbase::Wallet::APIError => e
    fail e.message, data['channel']
  end

  def rank data
    text = ""
    accounts = coinbase.accounts
    rank = 1
    accounts.collect{|a| [a.name, a.balance.amount.to_f]}.sort_by{|a| -a[1]}.each do |a|
      if rank > 20
        text << "..."
        break
      end
      username = get_user_name(a[0].split.last)
      next if username.nil?
      line = "##{rank} #{username}"
      line += "#{btc_to_bits(a[1])} bits".rjust(45-line.size)
      text << line + "\n"
      rank += 1
    end
    message(channel: data['channel'], text: "```#{text.strip}#{'\n...' if accounts.size > 20}```")
  end

  def get_user_name user_id
    $redis.hget 'users', user_id
  end

  def tipbot_user_id
    @tipbot_user_id ||= $redis.get('tipbot_user_id')
  end

  def fail message, channel
    web_message(attachments: [{color: 'danger', fallback: message, text: message}], channel: channel)
  end

  def message data
    $client.message(data)
  end

  def web_message data
    $client.web_client.chat_postMessage(data.merge(as_user: true))
  end

private

  def direct_message_channel user_id
    $client.web_client.get('/api/im.open', user: user_id)['channel']['id']

    ## For some reason caching it wasn't working, maybe the ids change periodically or if closed/opened
    # channel_id = nil #$redis.hget 'direct_message_channels', user_id
    # if channel_id.nil?
    #   # create it if it doesn't exist yet
    #   r = $client.web_client.get('/api/im.open', user: user_id)
    #   p r
    #   channel_id = r['channel']['id']
    #   $redis.hset 'direct_message_channels', user_id, channel_id
    # end
    # channel_id
  end

  def normalize_currency currency
    currency ||= "BTC"
    currency = "BTC" if "currency" == "bits"
    currency
  end

  def btc_to_bits btc
    (btc.to_f * 1_000_000).round
  end

  def bits_to_btc bits
    bits.to_f / 1_000_000
  end

  def account_key team_domain, user_name
    "#{team_domain} #{user_name}"
  end

  def find_or_create_account team, user
    raise "invalid team (#{team}) or user (#{user})" if team.nil? or user.nil?
    key = account_key(team, user)
    account_id = $redis.hget 'account_ids', key

    if account_id.nil?
      account = coinbase.create_account(name: key)
      $redis.hset 'account_ids', key, account.id.to_s
      account_id = account.id.to_s

      # put 100 bits in the account for free
      unless user == tipbot_user_id
        txn = @coinbase.primary_account.transfer(to: account_id, amount: "0.0001", currency: "BTC")
      end
    end

    account_id
  end

  def coinbase
    @coinbase ||= Coinbase::Wallet::Client.new(api_key: ENV['COINBASE_API_KEY'], api_secret: ENV['COINBASE_API_SECRET'])
  end

  def slack_oauth2_client
    @slack_client ||= OAuth2::Client.new(ENV['SLACK_CLIENT_ID'], ENV['SLACK_CLIENT_SECRET'], :site => 'https://slack.com', :authorize_url => '/oauth/authorize', :token_url => '/api/oauth.access')
  end

  def token team_domain
    hash = JSON.parse($redis.hget('oauth_tokens', team_domain))
    OAuth2::AccessToken.from_hash(slack_oauth2_client, hash)
  end

  def save_token team_domain, token
    $redis.hset('oauth_tokens', team_domain, token.to_hash.to_json)
  end
end
