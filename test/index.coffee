
config = require '../test'
they = require('../src').configure config

describe 'they', ->

  they 'return `true`', (ssh) ->
    true

  they 'return `{}`', (ssh) ->
    {}

  they 'return `Promise.resolve`', (ssh) ->
    new Promise (resolve) -> setImmediate resolve

  they 'call next synchronously', (ssh, next) ->
    next()

  they 'call next asynchronously', (ssh, next) ->
    setImmediate ->
      next()
