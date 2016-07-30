# notifyservice-ping-test.coffee
# Copyright 2016 9165584 Canada Corporation <legal@fuzzy.ai>
# All rights reserved.

util = require 'util'
http = require 'http'

async = require 'async'
vows = require 'vows'
assert = require 'assert'
request = require 'request'

{post, ClientError, ServerError} = require 'fuzzy.ai-web'

process.on 'uncaughtException', (err) ->
  console.error err

vows
  .describe('/ping endpoint')
  .addBatch
    'When we set up a mock Slack server':
      topic: ->
        callback = @callback
        slack = http.createServer (req, res) ->
          res.writeHead 200,
            'Content-Type': 'text/plain'
            'Content-Length': '0'
          res.end()
        slack.listen 1516, () ->
          callback null, slack
        undefined
      'it works': (err, slack) ->
        assert.ifError err
      teardown: (slack) ->
        callback = @callback
        slack.once 'close', ->
          callback null
        slack.close()
        undefined
      'and we start a NotifyService':
        topic: ->
          NotifyService = require '../lib/notifyservice'
          env =
            HOOK: "http://localhost:1516/post-message"
            PORT: "2342"
            HOSTNAME: "localhost"
            LOG_FILE: "/dev/null"
          service = new NotifyService env
          service.start (err) =>
            if err
              @callback err
            else
              @callback null, service
          undefined
        'it works': (err, service) ->
          assert.ifError err
        teardown: (service) ->
          callback = @callback
          service.stop (err) =>
            callback null
          undefined
        'and we ping it':
          topic: (service, slack) ->
            callback = @callback
            async.parallel [
              (callback) ->
                slack.once 'request', (req, res) ->
                  callback null
              (callback) ->
                url = 'http://localhost:2342/ping'
                props =
                  push_data:
                    pushed_at: 1453309389
                    images: []
                    pusher: "fuzzyio"
                  callback_url: "https://registry.hub.docker.com/u/fuzzyio/fakename/hook/22jjfbd1jej3c4giade134h122dhah33j/"
                  repository:
                    status: "Active"
                    description: "fakename.fuzzy.ai"
                    is_trusted: true
                    full_description: null
                    repo_url: "https://registry.hub.docker.com/u/fuzzyio/fakename/"
                    owner: "fuzzyio"
                    is_official: false
                    is_private: true
                    name: "fakename"
                    namespace: "fuzzyio"
                    star_count: 0
                    comment_count: 0
                    date_created: 1453153941
                    repo_name: "fuzzyio/fakename"
                headers =
                  "Content-Type": "application/json"
                post url, headers, JSON.stringify(props), (err, response) ->
                  if err
                    callback err
                  else
                    callback null
            ], (err) ->
              if err
                callback err
              else
                callback null
            undefined
          'it works': (err) ->
            assert.ifError err
  .export(module)
