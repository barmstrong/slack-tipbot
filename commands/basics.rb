# module SlackTipbot
#   module Commands
#     class Basics < SlackRubyBot::Commands::Base
#       command 'help' do |client, data, _match|
#         send_message client, data.channel, 'coming soon...'
#       end
#
#       command 'hi' do |client, data, _match|
#         send_message client, data.channel, "Hi <@#{data['user']}>!"
#       end
#     end
#   end
# end
