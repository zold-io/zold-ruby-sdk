# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2018-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'loog'
require 'minitest/autorun'
require 'webmock/minitest'
require_relative '../../lib/zold/wts'

# WTS test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2018-2026 Yegor Bugayenko
# License:: MIT
class TestWTS < Minitest::Test
  KEY = '0000000000000000-b416493aefae4ca487c4739050aaec15'

  def test_pulls
    WebMock.allow_net_connect!
    wts = Zold::WTS.new(KEY, log: Loog::VERBOSE)
    job = wts.pull
    wts.wait(job)
    assert(!job.nil?)
  end

  def test_finds_transactions
    WebMock.allow_net_connect!
    wts = Zold::WTS.new(KEY, log: Loog::VERBOSE)
    job = wts.pull
    wts.wait(job)
    assert_equal(0, wts.find(details: /^for hosting$/).count)
  end

  def test_retrieves_wallet_id
    WebMock.allow_net_connect!
    wts = Zold::WTS.new(KEY, log: Loog::VERBOSE)
    assert(!wts.id.nil?)
  end

  def test_retrieves_fake_usd_rate
    wts = Zold::WTS::Fake.new
    assert(!wts.usd_rate.nil?)
  end

  def test_retrieves_balance
    WebMock.allow_net_connect!
    wts = Zold::WTS.new(KEY, log: Loog::VERBOSE)
    job = wts.pull
    wts.wait(job)
    assert(!wts.balance.nil?)
  end

  def test_retrieves_usd_rate
    WebMock.allow_net_connect!
    wts = Zold::WTS.new(KEY, log: Loog::VERBOSE)
    rate = wts.usd_rate
    assert(!rate.nil?)
  end

  def test_works_with_fake
    WebMock.allow_net_connect!
    wts = Zold::WTS::Fake.new
    job = wts.pull
    wts.wait(job)
    assert(!wts.balance.zero?)
  end

  def test_works_with_webmock
    WebMock.disable_net_connect!
    stub_request(:get, 'https://wts.zold.io/usd_rate').to_return(body: '1.234')
    wts = Zold::WTS.new('fake', log: Loog::VERBOSE)
    assert_equal(1.234, wts.usd_rate)
  end

  def test_mobile_send
    WebMock.disable_net_connect!
    stub_request(:get, 'https://wts.zold.io/mobile/send')
      .with(query: hash_including(phone: '15551234567', noredirect: 'true'))
      .to_return(body: 'SMS #42 has been delivered to 15551234567')
    body = Zold::WTS.mobile_send('15551234567')

    assert_includes(body, '15551234567')
  end

  def test_mobile_token
    WebMock.disable_net_connect!
    stub_request(:get, 'https://wts.zold.io/mobile/token')
      .with(query: hash_including(phone: '15551234567', code: '1234'))
      .to_return(body: 'alice-token123')

    assert_equal('alice-token123', Zold::WTS.mobile_token('15551234567', '1234'))
  end

  def test_fake_mobile_send
    assert_equal('SMS sent', Zold::WTS::Fake.mobile_send('15551234567'))
  end

  def test_fake_mobile_token
    assert_includes(Zold::WTS::Fake.mobile_token('15551234567', '1234'), '-')
  end
end
