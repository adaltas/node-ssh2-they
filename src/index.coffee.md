
Extends mocha with a function similar to `it` but 
running both locally and remotely

    connect = require 'ssh2-connect'

    configure = (configs...) ->
      for config, i in configs
        configs[i] = config = {} unless config?
        configs[i].name ?= "#{i}.#{unless config.host then 'local' else 'remote'}"
        configs[i].ssh = !!config.host
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
          for config, i in configs
            unless config.ssh
            then it "#{msg} (#{config.name})", -> promise_local @, callback
            else it "#{msg} (#{config.name})", -> promise_remote @, callback
        else
          for config, i in configs
            unless config.ssh
            then it "#{msg} (#{config.name})", (next) -> callback_local @, callback, next
            else it "#{msg} (#{config.name})", (next) -> callback_remote @, callback, next
      they.only = (msg, callback) ->
        if callback.length is 1
          for config, i in configs
            unless config.ssh
            then it.only "#{msg} (#{config.name})", -> promise_local @, callback
            else it.only "#{msg} (#{config.name})", -> promise_remote @, callback
        else
          for config, i in configs
            unless config.ssh
            then it.only "#{msg} (#{config.name})", (next) -> callback_local @, callback, next
            else it.only "#{msg} (#{config.name})", (next) -> callback_remote @, callback, next
      they.skip = (msg, callback) ->
        if callback.length is 1
          for config, i in configs
            unless config.ssh
            then it.skip "#{msg} (#{config.name})", -> promise_local @, callback
            else it.skip "#{msg} (#{config.name})", -> promise_remote @, callback
        else
          for config, i in configs
            unless config.ssh
            then it.skip "#{msg} (#{config.name})", (next) -> callback_local @, callback, next
            else it.skip "#{msg} (#{config.name})", (next) -> callback_remote @, callback, next
      # Return the final result
      they
        
    module.exports = configure()
    
    module.exports.configure = (configs...) ->
      configure configs...
