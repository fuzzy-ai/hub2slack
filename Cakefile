fs = require "fs"

{print} = require "util"
{spawn} = require "child_process"

glob = require "glob"

DOCKER = "fuzzyio/hub2slack"

cmd = (str, callback) ->
  parts = str.split(" ")
  main = parts[0]
  rest = parts.slice(1)
  proc = spawn main, rest
  proc.stderr.on "data", (data) ->
    process.stderr.write data.toString()
  proc.stdout.on "data", (data) ->
    print data.toString()
  proc.on "exit", (code) ->
    callback?() if code is 0

build = (callback) ->
  cmd "coffee -c -o lib src", callback

buildDocker = (callback) ->
  cmd "sudo docker build -t #{DOCKER} .", callback

buildTest = (callback) ->
  cmd "coffee -c test", callback

task "build", "Build lib/ from src/", ->
  build()

task "build-test", "Build for testing", ->
  invoke "clean"
  invoke "build"
  buildTest()

task "watch", "Watch src/ for changes", ->
  coffee = spawn "coffee", ["-w", "-c", "-o", "lib", "src"]
  coffee.stderr.on "data", (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on "data", (data) ->
    print data.toString()

task "clean", "Clean up extra files", ->
  patterns = ["lib/*.js", "test/*.js", "*~", "lib/*~", "src/*~", "test/*~"]
  for pattern in patterns
    glob pattern, (err, files) ->
      for file in files
        fs.unlinkSync file

task "test", "Test the auth", ->
  invoke "clean"
  invoke "build"
  buildTest ->
    cmd "./node_modules/.bin/vows --spec -i test/*-test.js"

task "docker", "Build docker image", ->
  invoke "clean"
  build ->
    buildDocker()

task "push", "Push docker image", ->
  cmd "sudo docker push #{DOCKER}"
