# # all the /tip commands, instead of the ones going to @tipbot
#
# module SlackTipbot
#   module Commands
#     module Slash
#       def help params
#         {
#           text: "
# Usage: /tip @user [amount]
# Usage: /tip COMMAND
#
# Tipping
#
#   /tip @bob        # send @bob 10 bits
#   /tip @bob 1000   # send @bob 1000 bits
#   /tip @bob $5     # send @bob 5 U.S. dollars in bitcoin
#
# Commands
#
#   /tip balance     # shows your balance, 'bal' also works
#   /tip deposit     # reveal a bitcoin address
#   /tip withdraw    #
#           ".strip
#         }
#       end
#
#       def default params
#         r = help(params)
#         r[:text] = "I didn't recognize that command. Here is some help on usage...\n\n"+r[:text]
#         r
#       end
#
#       def send params
#         to_user_name, amount = params['text'].split
#         return {text: "Invalid syntax. Try /tip help"} unless to_user_name =~ /^@/
#         to_user_name = to_user_name[1..-1].downcase
#
#         from_account = find_or_create_account(params['team_domain'], params['user_name'])
#         to_account = find_or_create_account(params['team_domain'], to_user_name)
#
#         tx = coinbase.account(from_account).transfer(to: to_account, amount: bits_to_btc(amount), currency: 'BTC')
#         {text: "You sent #{btc_to_bits(tx.amount.amount)} bits to @#{to_user_name}!"}
#       rescue Coinbase::Wallet::APIError => e
#         {text: e.message}
#       end
#
#       def balance params
#         account_id = find_or_create_account(params['team_domain'], params['user_name'])
#         b = coinbase.account(account_id).balance
#         {text: "#{btc_to_bits(b.amount)} bits"}
#       # rescue Coinbase::Wallet::APIError => e
#       #   {text: e.message}
#       end
#
# private
#
#       def btc_to_bits btc
#         (btc.to_f * 1_000_000).round(2)
#       end
#
#       def bits_to_btc bits
#         bits.to_f / 1_000_000
#       end
#
#       def account_key team_domain, user_name
#         "#{team_domain} #{user_name}"
#       end
#
#       def find_or_create_account team_domain, user_name
#         key = account_key(team_domain, user_name)
#         account_id = $redis.hget 'account_ids', key
#
#         if account_id.nil?
#           account = coinbase.create_account(name: key)
#           $redis.hset 'account_ids', key, account.id.to_s
#           account_id = account.id.to_s
#
#           # put 100 bits in the account for free
#           puts "sending to #{account_id}"
#           txn = @coinbase.primary_account.transfer(to: account_id, amount: "0.0001", currency: "BTC")
#         end
#
#         account_id
#       end
#
#       def coinbase
#         @coinbase ||= Coinbase::Wallet::Client.new(api_key: ENV['COINBASE_API_KEY'], api_secret: ENV['COINBASE_API_SECRET'])
#       end
#
#       def slack_client
#         @slack_client ||= OAuth2::Client.new(ENV['SLACK_CLIENT_ID'], ENV['SLACK_CLIENT_SECRET'], :site => 'https://slack.com', :authorize_url => '/oauth/authorize', :token_url => '/api/oauth.access')
#       end
#
#       def token team_domain
#         hash = JSON.parse($redis.hget('oauth_tokens', team_domain))
#         OAuth2::AccessToken.from_hash(slack_client, hash)
#       end
#
#       def save_token team_domain, token
#         $redis.hset('oauth_tokens', team_domain, token.to_hash.to_json)
#       end
#     end
#   end
# end
