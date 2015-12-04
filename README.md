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

<a href="Add a new bot in slack" target="_blank">Add a new bot in slack</a>.

Give it a name, such as "tipbot". Then choose an emoji for it such as :money_mouth_face:.

Click "Save Integration". Leave this window open. You'll be needing that API token in a moment.

<img src="https://photos-3.dropbox.com/t/2/AACh0iWbxBPSSK_mwH3vDxIV2EBVG6F32fQI8OnzhpW_TQ/12/324237/png/32x32/3/1449273600/0/2/Screenshot%202015-12-04%2011.12.02.png/EK6YORjDv5K0AyACKAI/oi00v4CrYuijCa_D0GunX-qat8pD78BNgNjIvFuBq1c?size_mode=3&size=1600x1200" width="500">

### 2. Deploy the app

Tipbot run on the free tier of Heroku. The easiest way to deploy it is with the deploy button.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)



## Usage
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
