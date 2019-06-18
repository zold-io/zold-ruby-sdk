<img src="http://www.zold.io/logo.svg" width="92px" height="92px"/>

[![Donate via Zerocracy](https://www.0crat.com/contrib-badge/CAZPZR9FS.svg)](https://www.0crat.com/contrib/CAZPZR9FS)

[![EO principles respected here](http://www.elegantobjects.org/badge.svg)](http://www.elegantobjects.org)
[![Managed by Zerocracy](https://www.0crat.com/badge/CAZPZR9FS.svg)](https://www.0crat.com/p/CAZPZR9FS)
[![DevOps By Rultor.com](http://www.rultor.com/b/yegor256/zold)](http://www.rultor.com/p/yegor256/zold)
[![We recommend RubyMine](http://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![Build Status](https://travis-ci.org/zold-io/zold-ruby-sdk.svg)](https://travis-ci.org/zold-io/zold-ruby-sdk)
[![PDD status](http://www.0pdd.com/svg?name=zold-io/zold-ruby-sdk)](http://www.0pdd.com/p?name=zold-io/zold-ruby-sdk)
[![Gem Version](https://badge.fury.io/rb/zold-ruby-sdk.svg)](http://badge.fury.io/rb/zold-ruby-sdk)
[![Test Coverage](https://img.shields.io/codecov/c/github/zold-io/zold-ruby-sdk.svg)](https://codecov.io/github/zold-io/zold-ruby-sdk?branch=master)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/zold-io/zold-ruby-sdk/master/frames)

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/takes/blob/master/LICENSE.txt)
[![Hits-of-Code](https://hitsofcode.com/github/zold-io/zold-score)](https://hitsofcode.com/view/github/zold-io/zold-ruby-sdk)

Here is the [White Paper](https://papers.zold.io/wp.pdf).

Join our [Telegram group](https://t.me/zold_io) to discuss it all live.

This is a simple Ruby SDK for making payments, checking balances, and finding transactions in
Zold wallets via [WTS](https://wts.zold.io) system.

There are other languages too: [Java SDK](https://github.com/amihaiemil/zold-java-client).

First, you install it:

```
gem install zold-ruby-sdk
```

Then, you get your API key [here](https://wts.zold.io/api).

The, you make an instance of class `Zold::WTS`:

```ruby
require 'zold/wts'
wts = Zold::WTS.new(key)
```

Now you can pull your wallet and then check its balance:

```ruby
job = wts.pull # Initiate PULL and returns the unique ID of the job
wts.wait(job) # Wait for the job to finish
b = wts.balance # Retrieve the balance as an instance of Zold::Amount
puts b
```

To make a payment you will need to know your
[keygap](https://blog.zold.io/2018/07/18/keygap.html):

```ruby
job = wts.pay(keygap, 'yegor256', '19.95', 'For pizza') # Initiate a payment request
wts.wait(job) # Wait for the job to finish
```

To find a payment in your wallet, you do this (don't forget to `pull` first):

```ruby
# Finds all payments that match this query and returns
# an array of Zold::Txn objects.
txns = wts.find(id: '123', details: /pizza/)
```

That's it.

# How to contribute

Read [these guidelines](https://www.yegor256.com/2014/04/15/github-guidelines.html).
Make sure you build is green before you contribute
your pull request. You will need to have [Ruby](https://www.ruby-lang.org/en/) 2.3+ and
[Bundler](https://bundler.io/) installed. Then:

```
$ bundle update
$ rake
```

If it's clean and you don't see any error messages, submit your pull request.
