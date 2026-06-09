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

  def setup
    WebMock.disable_net_connect!
  end

  def test_pulls
    stub_request(:get, 'https://wts.zold.io/pull')
      .to_return(headers: { 'X-Zold-Job' => 'job-pull' })
    stub_request(:get, %r{https://wts\.zold\.io/job\?id=.*})
      .to_return(body: 'OK')
    wts = Zold::WTS.new(KEY, log: Loog::VERBOSE)
    job = wts.pull
    wts.wait(job)
    assert(!job.nil?)
  end

  def test_finds_transactions
    stub_request(:get, 'https://wts.zold.io/pull')
      .to_return(headers: { 'X-Zold-Job' => 'job-find' })
    stub_request(:get, %r{https://wts\.zold\.io/job\?id=.*})
      .to_return(body: 'OK')
    stub_request(:get, %r{https://wts\.zold\.io/find\?.*})
      .to_return(body: '')
    wts = Zold::WTS.new(KEY, log: Loog::VERBOSE)
    job = wts.pull
    wts.wait(job)
    assert_equal(0, wts.find(details: /^for hosting$/).count)
  end

  def test_retrieves_wallet_id
    stub_request(:get, 'https://wts.zold.io/id')
      .to_return(body: '0000000000000000')
    wts = Zold::WTS.new(KEY, log: Loog::VERBOSE)
    assert(!wts.id.nil?)
  end

  def test_retrieves_fake_usd_rate
    wts = Zold::WTS::Fake.new
    assert(!wts.usd_rate.nil?)
  end

  def test_retrieves_balance
    stub_request(:get, 'https://wts.zold.io/pull')
      .to_return(headers: { 'X-Zold-Job' => 'job-balance' })
    stub_request(:get, %r{https://wts\.zold\.io/job\?id=.*})
      .to_return(body: 'OK')
    stub_request(:get, 'https://wts.zold.io/balance')
      .to_return(body: '100000000')
    wts = Zold::WTS.new(KEY, log: Loog::VERBOSE)
    job = wts.pull
    wts.wait(job)
    assert(!wts.balance.nil?)
  end

  def test_retrieves_usd_rate
    stub_request(:get, 'https://wts.zold.io/usd_rate')
      .to_return(body: '5000.0')
    wts = Zold::WTS.new(KEY, log: Loog::VERBOSE)
    rate = wts.usd_rate
    assert(!rate.nil?)
  end

  def test_works_with_fake
    wts = Zold::WTS::Fake.new
    job = wts.pull
    wts.wait(job)
    assert(!wts.balance.zero?)
  end

  def test_works_with_webmock
    stub_request(:get, 'https://wts.zold.io/usd_rate').to_return(body: '1.234')
    wts = Zold::WTS.new('fake', log: Loog::VERBOSE)
    assert_equal(1.234, wts.usd_rate)
  end
end
