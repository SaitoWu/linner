# Linner

Linner is a full-featured HTML5 application assembler.

[![Code Climate](https://codeclimate.com/repos/520fd56e56b10241f50f15a3/badges/e8beb45f55b5c1fa6142/gpa.png)](https://codeclimate.com/repos/520fd56e56b10241f50f15a3/feed)

![Linner](http://d.pr/i/bWPA+)

#### Screencast

[![Screencast](http://d.pr/i/MIyk+)](https://vimeo.com/71944672)

* Fast!
* Supports `Sass`, `Compass` and `Coffee`.
* Supports OS X Lion and Mountaion Lion Notifications.
* Supports Modular Javascript, All your code will be wrap by `cmd`.
* Supports `concat` code by `config file` not `directive processor`.
* Supports `copy` code from `src` to `dest`.
* Supports Real-time `concat` by `$ linner watch`.
* Supports `compress` by `$ linner build`.
* Supports `LiveReload` with [LiveReload Chrome Extention](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei).

#### Documents

[https://github.com/SaitoWu/linner/tree/master/docs](https://github.com/SaitoWu/linner/tree/master/docs)

## Requirements

#### *nix

* Ruby 2.0

#### Windows

* JRuby 1.7.4 with 2.0 mode (`set JRUBY_OPTS=--2.0`)

## Installation

    $ gem install linner

## Usage

#### Skeleton

    $ linner new webapp && cd webapp

#### Watch

    $ linner watch

#### Server

    $ ./bin/server # or server if put "./bin" in your PATH

#### Build

    $ linner build

#### Clean

    $ linner clean

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
