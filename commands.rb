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

  @tipbot balance                              # shows your balance, 'bal' or 'b' also work
  @tipbot deposit                              # show a bitcoin address to add more funds
  @tipbot withdraw <amount> <address|email>    # withdraw to a bitcoin or email address
  @tipbot send <amount> <address|email>        # same as withdraw
  @tipbot leaderboard                          # see who has what, 'rank' also works

In direct message chat, you can issue these commands without prefixing '@tipbot ...'.```
\n
You can also tip people with reactions to their messages. Try 1bit :1bit:, 10bits :10bits:, 100bits :100bits:, and 1000bits :1000bits:.
      ".strip
    }
    message(response)
  end

  def default data
    message({channel: data['channel'], text: "I didn't recognize that command. Here is some help on usage..."})
    help(data)
  end

  def transfer data
    $client.typing channel: data['channel']
    command, to_user, amount, currency = data['text'].split
    currency = normalize_currency(currency)
    return {text: "Invalid syntax. Try 'help'"} unless to_user =~ /^<@.*>/
    to_user = to_user[2..-2]
    amount ||= 10

    transfer_helper data['channel'], data['user'], to_user, amount, currency
  rescue Coinbase::Wallet::APIError => e
    fail e.message, data['channel']
  end

  def transfer_helper channel, from_user, to_user, amount, currency, message_from_user=true, message_to_user=true
    from_account = find_or_create_account(from_user)
    to_account = find_or_create_account(to_user)
    return if from_account.nil? or to_account.nil? # occaisionally this happens if someones tries to tip a user who is no longer here

    amount2 = bits_to_btc(amount) if currency == 'BTC'
    tx = coinbase.account(from_account).transfer(to: to_account, amount: amount2 || amount, currency: currency)
    amount3 = btc_to_bits(tx.amount.amount)
    message(channel: channel, text: "Sent #{amount3} bits to <@#{to_user}>!") if message_from_user

    dm_channel = direct_message_channel(to_user)
    message(channel: dm_channel, text: "<@#{from_user}> sent you #{amount3} bits!") if message_to_user
  rescue Coinbase::Wallet::NotFoundError => e
    # our API incorrectly returns this error when there is insufficient balance right now
    if message_from_user
      fail "You don't have enough balance for that <@#{from_user}>", channel
    end
    if message_to_user
      dm_channel = direct_message_channel(to_user)
      account_id = find_or_create_account(to_user)
      b = coinbase.account(account_id).balance
      message(channel: dm_channel, text: "You don't have enough balance to tip #{amount3} bits. Your balance is #{btc_to_bits(b.amount)} bits.")
    end
  end

  def balance data
    command, currency = data['text'].split
    currency ||= "bits"

    currency.downcase!
    
    account_id = find_or_create_account(data['user'])
    b = coinbase.account(account_id).balance

    amount = convert_to_currency(b.amount, currency)

    currency.upcase! unless currency == "bits"

    message(channel: data['channel'], text: "You've got #{amount} #{currency} <@#{data['user']}>")
  rescue Coinbase::Wallet::APIError => e
    fail e.message, data['channel']
  rescue ArgumentError => e
    fail e.message, data['channel']
  end

  def deposit data
    account_id = find_or_create_account(data['user'])
    account = coinbase.account(account_id)
    addr = account.create_address
    msg = "You can send funds to `#{addr.address}` to raise your balance <@#{data['user']}>."
    web_message({
      text: msg,
      attachments: [
        {
          fallback: msg,
          title: "Deposit Bitcoin",
          title_link: "bitcoin:#{addr.address}",
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
    currency = normalize_currency(currency)
    account_id = find_or_create_account(data['user'])
    account = coinbase.account(account_id)
    if to =~ /<mailto:/
      to = to.match(/:(.*)\|/)[1] # strip email out
    end
    tx = account.send(to: to, amount: bits_to_btc(amount), currency: currency)
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

      username, user_id = a[0].split
      next if username.nil? or user_id.nil?
      next if $redis.hget('users', user_id) != username
      line = "##{rank} #{username}"
      line += "#{btc_to_bits(a[1])} bits".rjust(45-line.size)
      text << line + "\n"
      rank += 1
    end
    message(channel: data['channel'], text: "```#{text.strip}```")
  end

  # sample event: {"type"=>"reaction_added", "user"=>"U03JHBPLF", "item"=>{"type"=>"message", "channel"=>"C02TVNS00", "ts"=>"1449195825.004625"}, "reaction"=>"+1", "event_ts"=>"1449195859.610258"}
  REACTIONS = {
    '1bit'       => 1,
    '10bits'     => 10,
    '100bits'    => 100,
    '1000bits'   => 1000
  }
  def reaction_added data
    return unless REACTIONS.keys.include?(data['reaction'])
    return unless data['item']['type'] == 'message' # only matching reactions to messages for now, could add others in the future, would need to implement other apis below
    from_user_id = data['user']
    to_user_id = nil

    # choose the appropriate API to get history and find matching messaging, to see who to send it to
    r = case data['item']['channel'][0]
    when 'C'
      $client.web_client.get('/api/channels.history', channel: data['item']['channel'])
    when 'G'
      $client.web_client.get('/api/groups.history', channel: data['item']['channel'])
    when 'D'
      $client.web_client.get('/api/im.history', channel: data['item']['channel'])
    else
      puts "unknown channel for reaction #{data['channel']}"
    end
    r['messages'].each do |m|
      # match by timestamp, guaranteed to be unique per channel according to the docs
      if m['ts'] == data['item']['ts']
        p [:found, m['text'], m['user'], get_user_name(m['user'])]
        to_user_id = m['user']
        break
      end
    end

    return if from_user_id == to_user_id

    if to_user_id
      amount = REACTIONS[data['reaction']]
      transfer_helper data['item']['channel'], from_user_id, to_user_id, amount, 'BTC', false, true
    end

    # TODO if insufficient balance and transfer_helper fails, maybe we should remove the reaction
  rescue Coinbase::Wallet::APIError => e
    fail e.message, data['item']['channel']
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

  def convert_to_currency btc_amount, currency="bits"
    return btc_to_bits(btc_amount) if currency == "bits"

    rates = coinbase.exchange_rates(currency: 'BTC')
    ratio = rates.rates[currency.upcase]

    raise ArgumentError.new("Unknown currency: #{currency}") if ratio.nil?

    (btc_amount.to_f * ratio.to_f).round(8)
  end

  def account_key team_domain, user_name
    "#{team_domain} #{user_name}"
  end

  def find_or_create_account user_id
    raise "invalid user id" if user_id.nil?
    user_name = get_user_name(user_id)
    raise "invalid user name" if user_name.nil?
    key = "#{user_name} #{user_id}"
    account_id = $redis.hget 'account_ids', key

    if account_id.nil?
      account = coinbase.create_account(name: key)
      $redis.hset 'account_ids', key, account.id.to_s
      account_id = account.id.to_s

      # put 100 bits in the account for free
      unless user_id == tipbot_user_id
        begin
          txn = @coinbase.primary_account.transfer(to: account_id, amount: "0.0001", currency: "BTC")
        rescue Coinbase::Wallet::NotFoundError => e
          puts "Unable to fund new wallet! You may want to add more funds so every new user gets 100 bits for free."
        end
      end
    end

    account_id
  end

  def coinbase
    @coinbase ||= Coinbase::Wallet::Client.new(api_key: ENV['COINBASE_API_KEY'], api_secret: ENV['COINBASE_API_SECRET'])
  end
end
