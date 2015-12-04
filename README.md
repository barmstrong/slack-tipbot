# Slack Tipbot

Reward teammates in slack with bitcoin! Recognize greatness on your team with the future of money.

[animated gif here]

## Usage

```
Usage: tip @user [amount]

Tipping

  tip @bob            # send @bob 10 bits
  tip @bob 1000       # send @bob 1000 bits
  tip @bob 5 USD      # send @bob 5 U.S. dollars in bitcoin

Other Commands

  @tipbot balance                              # shows your balance, 'bal' also works
  @tipbot deposit                              # show a bitcoin address to add more funds
  @tipbot withdraw <amount> <address|email>    # withdraw to a bitcoin or email address
  @tipbot send <amount> <address|email>        # same as withdraw
  @tipbot leaderboard                          # see who has what, 'rank' also works

In direct message chat, you can issue these commands without prefixing '@tipbot ...'.
```

You can also tip people with reactions to their messages. Try 1bit <img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/1bit.png" width="22" height="22">, 10bits <img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/10bits.png" width="22" height="22">, 100bits <img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/100bits.png" width="22" height="22">, and 1000bits <img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/1000bits.png" width="22" height="22">.


## Installation

It takes 5-10 minutes to get a hosted copy of slack-tipbot up and running. Think you're up for it? Start your timers meow! :smiley_cat:

### 1. Create the bot

<a href="Add a new bot in slack" target='_blank'>Add a new bot in slack</a>.

Give it a name, such as "tipbot". Then choose an emoji for it such as :money_mouth_face:.

Click "Save Integration". Leave this window open. You'll be needing that API token in a moment.

<img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/screen1.png" width="750">

### 2. Create a Coinbase account

Slack-Tipbot keeps track of each user's balance in a separate wallet on Coinbase. This allows you to make transfers between accounts off-blockchain with zero fees.

If you already have a Coinbase account it is recommended to make a new one, since this app will create a lot of new wallets (one per user)!

[Create A Coinbase Account](https://www.coinbase.com/signup)

<img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/screen2.png" width="600">

Verify your email and skip the quick start.

[Create a Coinbase API Key](https://www.coinbase.com/settings/api) by clicking "New API Key" (you don't need OAuth2).

<img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/screen3.png" width="450" style="float: right;">

Under accounts check the box for "All", and under permissions check the box for `wallet:accounts:create`, `wallet:accounts:read`, `wallet:addresses:create`, `wallet:transactions:transfer`, and `wallet:transactions:send`.

Leave the rest of the settings blank and click "Create". You'll then need to "Enable" the key and click to reveal your key and secret. You'll need these in a moment.

Finally, it's a good idea to *fund the primary Coinbase wallet* with $5-10 of bitcoin. By default every new user in slack (when they first interact with tipbot) will get 100 bits in their account. This greatly increases adoption/usage of tipbot since there is nothing people need to set up to start tipping.

### 3. Deploy the app

Tipbot run on the free tier of Heroku. The easiest way to deploy it is with the Heroku deploy button.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Add an app name if you'd like (optional).

Then fill in the config variables that you generated in step 1 (SLACK_API_TOKEN) and step 2 (COINBASE_API_KEY and COINBASE_API_SECRET).

Deploy your app!

<img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/screen4.png" width="450">

Developers: If you have the app cloned locally for development you can add the heroku repository with `git remote add heroku git@heroku.com:YOURREPONAME.git`. Or clone a fresh copy with `git clone git@heroku.com:YOURREPONAME.git`.

Troubleshooting: See what is going on with `heroku logs -t` etc.

## Troubleshooting
Set up in your slack instance using the 'Add to slack' button [here/link].

- Send 10 bits: /tip @john 10
- Check your balance: @tipbot balance
- Deposit: @tipbot deposit
- Withdraw: @tipbot withdraw

## History
This tipping bot was created during the Coinbase hackathon in early December 2015.

## Contributing

Please do :) Fork, PR, all the standard stuff appreciated.

## Thanks

This project makes heavy use of the [slack-ruby-client](https://github.com/dblock/slack-ruby-client) by @dblock. Thank you!

## License

MIT License
