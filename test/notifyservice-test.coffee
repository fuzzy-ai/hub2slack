# notifyservice-test.coffee
# Copyright 2016 9165584 Canada Corporation <legal@fuzzy.ai>
# All rights reserved.

util = require 'util'

vows = require 'vows'
assert = require 'assert'
request = require 'request'

process.on 'uncaughtException', (err) ->
  console.error err

vows
  .describe('notifyservice')
  .addBatch
    'When we load the module':
      topic: ->
        callback = @callback
        try
          NotifyService = require '../lib/notifyservice'
          callback null, NotifyService
        catch err
          callback err
        undefined
      'it works': (err, NotifyService) ->
        assert.ifError err
      'it is a class': (err, NotifyService) ->
        assert.ifError err
        assert.isFunction NotifyService
      'and we instantiate a NotifyService':
        topic: (NotifyService) ->
          callback = @callback
          try
            env =
              PORT: "2342"
              HOSTNAME: "localhost"
              LOG_FILE: "/dev/null"
            server = new NotifyService env
            callback null, server
          catch err
            callback err
          undefined
        'it works': (err, server) ->
          assert.ifError err
        'it is an object': (err, server) ->
          assert.ifError err
          assert.isObject server
        'it has a start() method': (err, server) ->
          assert.ifError err
          assert.isObject server
          assert.isFunction server.start
        'it has a stop() method': (err, server) ->
          assert.ifError err
          assert.isObject server
          assert.isFunction server.stop
        'and we start the server':
          topic: (server) ->
            callback = @callback
            server.start (err) ->
              if err
                callback err
              else
                callback null
            undefined
          'it works': (err) ->
            assert.ifError err
          'and we request the version':
            topic: () ->
              callback = @callback
              url = 'http://localhost:2342/version'
              request.get url, (err, response, body) ->
                if err
                  callback err
                else if response.statusCode != 200
                  callback new Error("Bad status code #{response.statusCode}")
                else
                  body = JSON.parse body
                  callback null, body
              undefined
            'it works': (err, version) ->
              assert.ifError err
            'it looks correct': (err, version) ->
              assert.ifError err
              assert.include version, "version"
              assert.include version, "name"
            'and we stop the server':
              topic: (version, server) ->
                callback = @callback
                server.stop (err) ->
                  if err
                    callback err
                  else
                    callback null
                undefined
              'it works': (err) ->
                assert.ifError err
              'and we request the version':
                topic: ->
                  callback = @callback
                  url = 'http://localhost:2342/version'
                  request.get url, (err, response, body) ->
                    if err
                      callback null
                    else
                      callback new Error("Unexpected success after server stop")
                  undefined
                'it fails correctly': (err) ->
                  assert.ifError err
  .export(module)
