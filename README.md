
Node.js ssh2-they
=================

Extends [Mocha][mocha] with a new `they` function replacing `it`. The goal is 
to execute tests twice on ssh and non-ssh environments. This package was originally 
written to test the "ssh2-fs", "ssh2-exec" and "nikita". All the tests in 
those modules work on a local environment or over SSH transparently.

The main module of this package doesn't take any option and will attempt to open a passwordless ssh connection on localhost with the current running user. Thus, it expects 
correct deployment of your ssh public key inside your own authorized_key file.

Additionally, you can call the `configure` function which expect an SSH configuration. Refer to the ["ssh2-connect"](https://github.com/adaltas/node-ssh2-connect) and ["ssh2"](https://github.com/mscdex/ssh2) packages for a complete list of supported options.

Installation
------------

This is OSS and licensed under the [new BSD license][license].

```bash
npm install ssh2-fs
```

## Examples

The below examples found inspiration in the [exists test](https://github.com/adaltas/node-ssh2-fs/blob/master/test/exists.coffee) of the [ssh2-fs module](https://github.com/adaltas/node-ssh2-fs).

This test will connect to localhost with the current working user:

```js
const should = require('should')
const fs = require('ssh2-fs')
const they = require('ssh2-they')

describe('exists', function(){
  they('on file', function(ssh, next){
    fs.exists( ssh, "#{__filename}", function(err, exists){
      exists.should.be.true()
      next()
    })
  })
})
```

This test will attempt a remote connection using the root user:


```js
const should = require('should')
const fs = require('ssh2-fs')
const they = require('ssh2-they').configure({
  host: 'localhost',
  port: 22,
  username: 'root',
  privateKey: require('fs').readFileSync('/here/is/my/key')
})

describe('exists', function(){
  they('on file', function(ssh, next){
    fs.exists( ssh, "#{__filename}", function(err, exists){
      exists.should.be.true()
      next()
    })
  })
})
```

## Travis integration

You can make it work with [Travis][travis] by adding the following lines to 
your ".travis.yml" file:

before_script:
  - "ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''"
  - "cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys"

## Contributors

*   David Worms: <https://github.com/wdavidw>

[ssh2]: https://github.com/mscdex/ssh2
[license]: https://github.com/adaltas/node-ssh2-they/blob/master/LICENSE.md
[travis]: https://travis-ci.org/
