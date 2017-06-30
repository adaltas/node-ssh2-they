
Extends mocha with a function similar to `it` but 
running both locally and remotely

    connect = require 'ssh2-connect'

    promise_local = (context, callback) ->
      callback.call context, null

    promise_remote = (context, callback) ->
      new Promise (resolve, reject) ->
        connect host: 'localhost', (err, ssh) ->
          close = (callback) ->
            open = ssh._sshstream?.writable and ssh._sock?.writable
            return callback() unless open
            ssh.end()
            ssh.on 'end', ->
              process.nextTick -> callback()
          return next err if err
          p = callback.call context, ssh, (err) ->
          p.then ->
            close -> resolve()
          , (err) ->
            close -> reject err
    
    callback_local = (context, callback, next) ->
      callback.call context, null, next
      return null
    
    callback_remote = (context, callback, next) ->
      connect host: 'localhost', (err, ssh) ->
        return next err if err
        callback.call context, ssh, (err) ->
          open = ssh._sshstream?.writable and ssh._sock?.writable
          return next() unless open
          ssh.end()
          ssh.on 'end', ->
            process.nextTick -> next err

    they = (msg, callback) ->
      if callback.length is 1
        it "#{msg} (local)", -> promise_local @, callback
        it "#{msg} (remote)", -> promise_remote @, callback
      else
        it "#{msg} (local)", (next) -> callback_local @, callback, next
        it "#{msg} (remote)", (next) -> callback_remote @, callback, next
    
    they.only = (msg, callback) ->
      if callback.length is 1
        it.only "#{msg} (local)", -> promise_local @, callback
        it.only "#{msg} (remote)", -> promise_remote @, callback
      else
        it.only "#{msg} (local)", (next) -> callback_local @, callback, next
        it.only "#{msg} (remote)", (next) -> callback_remote @, callback, next

    they.skip = (msg, callback) ->
      if callback.length is 1
        it.skip "#{msg} (local)", -> promise_local @, callback
        it.skip "#{msg} (remote)", -> promise_remote @, callback
      else
        it.skip "#{msg} (local)", (next) -> callback_local @, callback, next
        it.skip "#{msg} (remote)", (next) -> callback_remote @, callback, next

    module.exports = they
