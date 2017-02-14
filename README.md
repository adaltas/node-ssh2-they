
Node.js ssh2-they
=================

Extends [Mocha][mocha] with a new `they` function replacing `it`. The goal is 
to execute tests on ssh and non-ssh environment. This module was originally 
written to test the "ssh2-fs", "ssh2-exec" and "mecano". All the functions in 
those modules work on a local environment or over SSH transparently.

This module doesn't take any option and will attempt to open a passwordless
ssh connection on localhost with the current running user. Thus, it expect 
correct deployment of your ssh public key inside your own authorized_key file.

You can make it work with [Travis][travis] by adding the following lines to 
your ".travis.yml" file:

before_script:
  - "ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''"
  - "cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys"

Installation
------------

This is OSS and licensed under the [new BSD license][license].

```bash
npm install ssh2-fs
```

Examples
--------

The example is extracted from the [exists test][exists] of the [ssh2-fs module][fs].

```js
should = require 'should'
test = require './test'
they = require 'ssh2-they'
fs = require '../src'

describe 'exists', ->

  they 'on file', test (ssh, next) ->
    fs.exists ssh, "#{__filename}", (err, exists) ->
      exists.should.be.ok
      next()

```

Contributors
------------

*   David Worms: <https://github.com/wdavidw>

[fs]: https://github.com/adaltas/node-ssh2-fs
[exists]: https://github.com/adaltas/node-ssh2-fs/blob/master/test/exists.coffee
[ssh2]: https://github.com/mscdex/ssh2
[license]: https://github.com/adaltas/node-ssh2-they/blob/master/LICENSE.md
[travis]: https://travis-ci.org/
