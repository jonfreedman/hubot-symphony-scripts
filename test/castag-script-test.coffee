#
#    Copyright 2016 The Symphony Software Foundation
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

Helper = require('hubot-test-helper')
expect = require('chai').expect
nock = require 'nock'

helper = new Helper('../src/cashtag-script.coffee')

describe 'CashTag price lookup test suite', () ->

  beforeEach ->
    @room = helper.createRoom()
    nock.disableNetConnect()
    @markitScope = nock('http://dev.markitondemand.com/')
      .get('/MODApis/Api/v2/Quote/json?symbol=AAPL')
      .reply(200, {
        Status: "SUCCESS"
        Name: "Apple Inc"
        Symbol: "AAPL"
        LastPrice: 104.19
        Change: -0.019999999999996
        ChangePercent: -0.0191920161212897
        Timestamp: "Fri Jul 29 00:00:00 UTC-04:00 2016"
        MSDate: 42580
        MarketCap: 561421876170
        Volume: 27733688
        ChangeYTD: 105.26
        ChangePercentYTD: -1.01653049591488
        High: 104.55
        Low: 103.68
        Open: 104.19
      })
      .get('/MODApis/Api/v2/Quote/json?symbol=MSFT')
      .reply(200, {
        Status: "SUCCESS"
        Name: "Microsoft Corp"
        Symbol: "MSFT"
        LastPrice: 56.69
        Change: 0.00999999999999801
        ChangePercent: 0.0176429075511609
        Timestamp: "Fri Jul 29 00:00:00 UTC-04:00 2016"
        MSDate: 42580
        MarketCap: 441757732040
        Volume: 30558718
        ChangeYTD: 55.48
        ChangePercentYTD: 2.18096611391493
        High: 56.76
        Low: 56.05
        Open: 56.26
      })

  afterEach ->
    nock.cleanAll()
    @room.destroy()

  it 'matches a single cashtag', ->
    @room.user.say('alice', '<cash tag="AAPL"/>').then =>
      expect(@room.messages).to.eql [
        ['alice', '<cash tag="AAPL"/>']
        ['hubot', '<cash tag="AAPL"/> @ 104.19']
      ]

  it 'matches multiple cashtags', ->
    @room.user.say('alice', 'Whats the price of <cash tag="AAPL"/> & <cash tag="MSFT"/>?').then =>
      expect(@room.messages).to.eql [
        ['alice', 'Whats the price of <cash tag="AAPL"/> & <cash tag="MSFT"/>?']
        ['hubot', '<cash tag="AAPL"/> @ 104.19']
        ['hubot', '<cash tag="MSFT"/> @ 56.69']
      ]
