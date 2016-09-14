# Slack Bitcoin Tipbot

Reward teammates in slack with bitcoin! Recognize greatness on your team with the future of currency.

<img src="http://i.imgur.com/tayZDCq.gif" width="750">

## Usage

```
Usage: tip @user [amount]

Tipping

  tip @bob            # send @bob 10 bits
  tip @bob 1000       # send @bob 1000 bits
  tip @bob 5 USD      # send @bob 5 U.S. dollars in bitcoin

Other Commands

  @tipbot balance <currency>                   # shows your balance, 'bal' also works
  @tipbot deposit                              # show a bitcoin address to add more funds
  @tipbot withdraw <amount> <address|email>    # withdraw to a bitcoin or email address
  @tipbot send <amount> <address|email>        # same as withdraw
  @tipbot leaderboard <currency>               # see who has what, 'rank' also works

In direct message chat, you can issue these commands without prefixing '@tipbot ...'.
```

You can also tip people with reactions to their messages. Try 1bit <img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/1bit.png" width="22" height="22">, 10bits <img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/10bits.png" width="22" height="22">, 100bits <img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/100bits.png" width="22" height="22">, and 1000bits <img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/1000bits.png" width="22" height="22">.


## Installation

It takes 5-10 minutes to get a hosted copy of slack-tipbot up and running. Do you trust me? Ok, let's get started...:smiley_cat:

### 1. Create the slack bot

<a href="https://my.slack.com/services/new/bot" target='_blank'>Add a new bot in slack</a> for your team.

Give it a name, such as "tipbot". Then choose an emoji for it such as :money_mouth_face:.

<img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/screen1.png" width="750">

Click "Save Integration". Leave this window open. You'll be needing that API token in a moment.

### 2. Create a Coinbase account

Coinbase allows you to create a separate wallet for each slack user and transfer tiny amounts between them with zero fees (off blockchain), which is perfect for tipping.

If you already have a Coinbase account it is recommended to make a new one, since this app will create a lot of new wallets (one per user)!

<a href="https://www.coinbase.com/signup" target="_blank">Create A Coinbase Account</a>

<img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/screen2.png" width="600">

Verify your email and skip the quick start.

<a href="https://www.coinbase.com/settings/api" target="_blank">Create a Coinbase API Key</a> by clicking "New API Key".

<img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/screen3.png" width="450" style="float: right;">

Under accounts check the box for `all`, and under permissions check the box for `wallet:accounts:create`, `wallet:accounts:read`, `wallet:addresses:create`, `wallet:transactions:transfer`, and `wallet:transactions:send`.

Leave the rest of the settings blank and click "Create". You'll then need to "Enable" the key and click it to reveal the full key and secret. We'll use these in a moment.

Finally, it's a good idea to *fund your Coinbase account* with at least a few dollars of bitcoin. By default every new user in slack (when they first interact with tipbot) will get 100 bits in their account. This greatly increases adoption/usage of tipbot since there is nothing people need to set up to do their first few tips.

If you have an existing Coinbase account, you can send some bitcoin to this new account via email or bitcoin address.

### 3. Deploy the app

Tipbot runs on the free tier of Heroku. The easiest way to deploy it is with the Heroku deploy button.

<a href="https://heroku.com/deploy"><img src="https://www.herokucdn.com/deploy/button.svg" target="_blank"></a>

Add an app name if you'd like (optional).

Then fill in the config variables that you generated in step 1 (SLACK_API_TOKEN) and step 2 (COINBASE_API_KEY and COINBASE_API_SECRET).

<img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/screen4.png" width="450">

Finally, click "Deploy for Free"!

### 4. Test it out!

The `@tipbot` user should appear in your company Slack.

Try sending a direct message to `@tipbot` in private chat, or `/invite @tipbot` to any channel or group. Use `@tipbot help` for a list of commands or try using the `tip @user 10` command.

### 5. Add custom emoji

To get reaction tipping working, you should [add some custom emoji in Slack](https://my.slack.com/customize/emoji).

We recommend the following images to associate with each name.

<img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/1bit.png" width="22" height="22"> 1bit

<img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/10bits.png" width="22" height="22"> 10bits

<img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/100bits.png" width="22" height="22"> 100bits

<img src="https://raw.githubusercontent.com/barmstrong/slack-tipbot/master/images/1000bits.png" width="22" height="22"> 1000bits

These are located in the [images folder on github](https://github.com/barmstrong/slack-tipbot/tree/master/images) for easy downloading.

You can use any custom images you'd like linked to those names, and they will work. Or modify the source code to support other emoji reactions.

## Troubleshooting

Use the `heroku logs -t` command to see what is going on, any error messages, etc. [Open an issue](https://github.com/barmstrong/slack-tipbot/issues/new) if you encounter problems.

## Heroku Idling

Heroku free tier applications will idle when not in use. Either pay $7 a month for the hobby dyno or use [UptimeRobot](http://uptimerobot.com/), [Pingdom](https://www.pingdom.com/), or similar to prevent your instance from sleeping.

## Contributing

Pull requests are welcome. I'm curious what improvements/modifications people can make. What else should it support? With Slack's popularity, this has the potential to introduce thousands (millions?) of new people to bitcoin, given the ease of getting started. It takes just one person to add it to a team.

## History
Slack Tipbot was created during the Coinbase hackathon in early December 2015. If you're interested in learning more about working at Coinbase [send us a note](https://www.coinbase.com/careers). We'd like the world to have an open payment network.

## Shout Outs

This project makes heavy use of the [slack-ruby-client](https://github.com/dblock/slack-ruby-client) by @dblock. Thank you!
