
Extends mocha with a function similar to `it` but 
running both locally and remotely

    connect = require 'ssh2-connect'

    configure = (config={}) ->
      # Local execution for promises
      promise_local = (context, callback) ->
        callback.call context, null
      # Remote execution for promises
      promise_remote = (context, callback) ->
        new Promise (resolve, reject) ->
          config.host ?= 'localhost'
          connect config, (err, ssh) ->
            close = (callback) ->
              open = ssh._sshstream?.writable and ssh._sock?.writable
              return callback() unless open
              ssh.end()
              ssh.on 'end', ->
                process.nextTick -> callback()
            return reject err if err
            try
              p = callback.call context, ssh, (err) ->
            catch err
              # Sync through throw error
              reject err
            # Async through promise
            if p
              p.then ->
                close -> resolve()
              , (err) ->
                close -> reject err
            # Sync through return
            else close -> resolve()
      # Local execution for callbacks
      callback_local = (context, callback, next) ->
        callback.call context, null, next
        return null
      # Remote execution for callbacks
      callback_remote = (context, callback, next) ->
        config.host ?= 'localhost'
        connect config, (err, ssh) ->
          return next err if err
          callback.call context, ssh, (err) ->
            open = ssh._sshstream?.writable and ssh._sock?.writable
            return next() unless open
            ssh.end()
            ssh.on 'end', ->
              process.nextTick -> next err
      # Define our main entry point
      they = (msg, callback) ->
        if callback.length is 1
          it "#{msg} (local)", ->
            promise_local @, callback
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
      # Return the final result
      they
        
    module.exports = configure()
    
    module.exports.configure = (config) ->
      configure config
