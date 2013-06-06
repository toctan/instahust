# instahust

Instahust is a simple tool which syncs Instagram photos tagged with
instahust to Weibo.  The original instahust was implemented by
[pyrocat101](https://github.com/pyrocat101). This is the ruby
implementation with some enhacements, including job queue and
exception notification via email.

![instahust](http://distilleryimage0.s3.amazonaws.com/ceca1cacc35f11e2b56022000a9f1354_7.jpg)

Behind the tag [#instahust](http://statigr.am/tag/instahust) is a
group of college students trying to record the school life in HUST
using Instagram. You can follow us on [weibo](http://weibo.com/instahust).

## Installation

Make sure you have redis installed, then run

```
git clone https://github.com/toctan/instahust.git
cd instahust && bundle install
```

Rename `.env.sample` to `.env`, and edit it accordingly.  Start the
server with
```
bundle exec foreman start
```

Then, create a Instagram tag subscription:
```ruby
bundle exec foreman run rake create_sub
```

Finally, go to Instagram, tag a photo and enjoy.

## Deploy to Heroku

Install the heroku config plugin if you havn't:
```
heroku plugins:install git://github.com/ddollar/heroku-config.git
```

Create the app and **change the DOMAIN** in `.env`, push the config
to Heroku

```
heroku create          # => change the DOMAIN in .env before next command
heroku config:push
git push heroku master
```

Create the subscription with
```
heroku run rake create_sub
```

## LICENSE
MIT
