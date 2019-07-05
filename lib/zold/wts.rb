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

require 'typhoeus'
require 'cgi'
require 'loog'
require 'zold/age'
require 'zold/amount'
require 'zold/id'
require 'zold/txn'

# WTS gateway.
#
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2018-2019 Yegor Bugayenko
# License:: MIT
class Zold::WTS
  # Fake implementation.
  class Fake
    def pull
      'job-id'
    end

    def balance
      Zold::Amount.new(zld: 4.0)
    end

    def id
      Zold::Id::ROOT
    end

    def pay(_keygap, _bnf, _amount, _details)
      'job-id'
    end

    def find(_query)
      []
    end

    def wait(_job, time: 5 * 60)
      raise 'Time must be positive' if time.negative?
      'OK'
    end
  end

  # Makes a new object of the class. The <tt>key</tt> you are supposed
  # to obtain at this page: https://wts.zold.io/api. You will have to login
  # and confirm your account first. Keep this key secret, to avoid
  # information lost. However, even knowing the secret no payments can
  # be sent without they keygap.
  def initialize(key, log: Loog::NULL)
    raise 'Key can\'t be nil' if key.nil?
    @key = key
    raise 'Log can\'t be nil' if log.nil?
    @log = log
  end

  # Initiate PULL request. The server will pull your wallet form the network,
  # and make it ready for future requests. Without this operation you won't
  # be able to perform <tt>find()</tt> or <tt>balance()</tt> requests.
  #
  # The method returns the job ID, which you should wait for completion
  # using the method <tt>wait()</tt>.
  def pull
    start = Time.now
    job = job_of(
      clean(
        Typhoeus::Request.get(
          'https://wts.zold.io/pull',
          headers: headers
        )
      )
    )
    @log.debug("PULL job #{job} started in #{Zold::Age.new(start)}")
    job
  end

  # Get wallet balance.
  def balance
    start = Time.now
    http = clean(
      Typhoeus::Request.get(
        'https://wts.zold.io/balance',
        headers: headers
      )
    )
    balance = Zold::Amount.new(zents: http.body.to_i)
    @log.debug("The balance #{balance} retrieved in #{Zold::Age.new(start)}")
    balance
  end

  # Get wallet ID.
  def id
    start = Time.now
    http = clean(
      Typhoeus::Request.get(
        'https://wts.zold.io/id',
        headers: headers
      )
    )
    id = Zold::Id.new(http.body.to_s)
    @log.debug("Wallet ID #{id} retrieved in #{Zold::Age.new(start)}")
    id
  end

  # Initiate PAY request. The <tt>keygap</tt> is a string you get
  # when you confirm the account. The <tt>bnf</tt> is the name of the
  # GitHub account, the wallet ID or the invoice (up to you). The
  # <tt>amount</tt> is the amount in ZLD, e.g. "19.99". The <tt>details</tt>
  # is the text to add to the transaction.
  #
  # The method returns the job ID, which you should wait for completion
  # using the method <tt>wait()</tt>.
  def pay(keygap, bnf, amount, details)
    start = Time.now
    job = job_of(
      clean(
        Typhoeus::Request.post(
          'https://wts.zold.io/do-pay',
          headers: headers,
          body: { keygap: keygap, bnf: bnf, amount: amount, details: details }
        )
      )
    )
    @log.debug("PAY job #{job} started in #{Zold::Age.new(start)}")
    job
  end

  # Returns current USD rate of one ZLD.
  def usd_rate
    clean(Typhoeus::Request.get('https://wts.zold.io/usd_rate')).body.to_f
  end

  # Find transactions by the criteria. All criterias are regular expressions
  # and their summary result is concatenated by OR. For example, this request
  # will return all transactions that have "pizza" in details OR which
  # are coming from the root wallet:
  #
  #  find(details: /pizza/, bnf: '0000000000000000')
  #
  # The method returns an array of Zold::Txn objects.
  def find(query)
    start = Time.now
    http = clean(
      Typhoeus::Request.get(
        'https://wts.zold.io/find?' + query.map do |k, v|
          "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
        end.join('&'),
        headers: headers
      )
    )
    txns = http.body.split("\n").map { |t| Zold::Txn.parse(t) }
    @log.debug("#{txns.count} transactions found in #{Zold::Age.new(start)}")
    txns
  end

  # Wait for the job to complete. If the job completes successfully, the
  # method returns 'OK' in a few seconds (up to a few minutes). If the
  # is some error, the exception will be raised.
  def wait(job, time: 5 * 60)
    start = Time.now
    loop do
      if Time.now - start > time
        raise "Can't wait any longer for the job #{job} to complete"
      end
      http = Typhoeus::Request.get(
        'https://wts.zold.io/job?id=' + job,
        headers: headers
      )
      raise "Job #{job} not found on the server" if http.code == 404
      raise "Unpredictable response code #{http.code}" unless http.code == 200
      if http.body == 'Running'
        @log.debug("Job #{job} is still running, \
#{Zold::Age.new(start)} already...")
        sleep 1
        next
      end
      raise http.body unless http.body == 'OK'
      @log.debug("Job #{job} completed, in #{Zold::Age.new(start)}")
      return http.body
    end
  end

  private

  def headers
    {
      'X-Zold-WTS': @key,
      'User-Agent': 'zold-ruby-sdk'
    }
  end

  def job_of(http)
    job = http.headers['X-Zold-Job']
    raise 'Job ID is not returned, for some reason' if job.nil?
    job
  end

  def clean(http)
    error = http.headers['X-Zold-Error']
    raise error unless error.nil?
    unless http.code == 200 || http.code == 302
      @log.debug(http.body)
      raise "Unexpected response code #{http.code}"
    end
    http
  end
end
