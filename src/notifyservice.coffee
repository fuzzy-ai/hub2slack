# notifyservice.coffee
# Copyright 2016 9165584 Canada Corporation <legal@fuzzy.io>
# All rights reserved.

Microservice = require 'fuzzy.io-microservice'
{post, ClientError, ServerError} = require 'fuzzy.io-web'

version = require './version'

passthru = (callback) ->
  callback null

class NotifyService extends Microservice

  startDatabase: passthru
  stopDatabase: passthru

  getName: () -> "hub2slack"

  environmentToConfig: (env) ->

    cfg = super env
    cfg.hook = env['HOOK']
    cfg

  setupRoutes: (exp) ->

    exp.get '/version', (req, res, next) ->
      res.json {name: @getName(), version: version}

    exp.post '/ping', (req, res, next) ->
      hook = req.app.config.hook
      event = req.body
      name = event?.repository?.repo_name
      pusher = event?.push_data?.pusher
      dt = (new Date(event?.push_data?.pushed_at)).toString()
      props =
        text: "#{pusher} pushed a new image to #{name} at #{dt}"
        username: "hub2slack"
        icon_emoji: ":whale:"
      headers =
        "Content-Type": "application/json"
      post hook, headers, JSON.stringify(props), (err) ->
        if err
          console.error err

module.exports = NotifyService
