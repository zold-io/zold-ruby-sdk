# frozen_string_literal: true

# Copyright (c) 2018-2019 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'minitest/autorun'
require_relative '../../lib/zold/wts'

# WTS test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2018-2019 Yegor Bugayenko
# License:: MIT
class TestWTS < Minitest::Test
  KEY = '8HNxjYuEFp0....LYOWxsEaC3rQ=='

  def test_pulls
    skip if KEY.length < 50
    wts = Zold::WTS.new(KEY)
    job = wts.pull
    wts.wait(job)
    assert(!job.nil?)
  end

  def test_finds_transactions
    skip if KEY.length < 50
    wts = Zold::WTS.new(KEY)
    job = wts.pull
    wts.wait(job)
    assert_equal(1, wts.find(details: /^for hosting$/).count)
  end

  def test_retrieves_wallet_id
    skip if KEY.length < 50
    wts = Zold::WTS.new(KEY)
    assert(!wts.id.nil?)
  end

  def test_retrieves_balance
    skip if KEY.length < 50
    wts = Zold::WTS.new(KEY)
    job = wts.pull
    wts.wait(job)
    assert(!wts.balance.zero?)
  end
end
