# notifyservice.coffee
# Copyright 2016 9165584 Canada Corporation <legal@fuzzy.io>
# All rights reserved.

async = require 'async'

Microservice = require 'fuzzy.io-microservice'
{post, ClientError, ServerError} = require 'fuzzy.io-web'

version = require './version'

passthru = (callback) ->
  callback null

class NotifyService extends Microservice

  constructor: (env) ->
    super env

  startDatabase: passthru
  stopDatabase: passthru

  getName: () -> "hub2slack"

  environmentToConfig: (env) ->

    cfg = super env
    cfg.hook = env.HOOK
    cfg

  setupRoutes: (exp) ->

    notify = (task, callback) ->
      {hook, event} = task
      name = event?.repository?.repo_name
      url = event?.repository?.repo_url
      pusher = event?.push_data?.pusher
      dt = (new Date(event?.push_data?.pushed_at*1000)).toString()
      props =
        text: "<https://hub.docker.com/u/#{pusher}/|#{pusher}> pushed a new image of <#{url}|#{name}> at #{dt}"
        username: "hub2slack"
        icon_emoji: ":whale:"
      headers =
        "Content-Type": "application/json"
      post hook, headers, JSON.stringify(props), (err) ->
        if err
          callback err
        else
          callback null

    q = async.queue notify, 4

    exp.get '/version', (req, res, next) =>
      res.json {name: @getName(), version: version}

    exp.post '/ping', (req, res, next) ->
      hook = req.app.config.hook
      event = req.body
      log = req.log
      q.push {hook: hook, event: event}, (err) ->
        if err
          # Queue again
          log.error {err: err, status: "Unsuccessful notification"}
        else
          log.info {status: "Successful notification"}
      res.status(204).end()

module.exports = NotifyService
