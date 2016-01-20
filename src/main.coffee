# main.coffee
# Copyright 2016 9165584 Canada Corporation <legal@fuzzy.io>
# All rights reserved.

NotifyService = require './notifyservice'

service = new NotifyService(process.env)

service.start (err) ->
  if err
    console.error(err)
  else
    console.log("Service started.")
