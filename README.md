# Linner

[![Gem Version](https://badge.fury.io/rb/linner.png)](http://badge.fury.io/rb/linner)   [![Build Status](https://travis-ci.org/SaitoWu/linner.png)](https://travis-ci.org/SaitoWu/linner)   [![Code Climate](https://codeclimate.com/repos/520fd56e56b10241f50f15a3/badges/e8beb45f55b5c1fa6142/gpa.png)](https://codeclimate.com/repos/520fd56e56b10241f50f15a3/feed)   [![Dependency Status](https://gemnasium.com/SaitoWu/linner.png)](https://gemnasium.com/SaitoWu/linner)

Linner is a full-featured HTML5 application assembler.

![Linner](http://cl.ly/image/2J0d1C0D3S0E/logo.png)

#### Screencast

[![Screencast](http://cl.ly/image/000k0R400F30/Image%202014-04-29%20at%2010.20.12%20AM.png)](https://vimeo.com/71944672)

* Fast!
* Supports `Sass`, `Compass`, `Coffee`, `ECMAScript 6` and `React`.
* Supports OS X Lion and Mountaion Lion Notifications.
* Supports Modular Javascript, All your code will be wrapped by `cmd`.
* Supports `concat` code by `config file` not `directive processor`.
* Supports `copy` code from `src` to `dest`.
* Supports `precompile` Javascript Templates from `src` to `desc`.
* Supports `sprite` PNG images from `src` to `desc`.
* Supports `tar` files from `src` to `desc`.
* Supports Real-time `concat` by `$ linner watch`.
* Supports `compress` by `$ linner build`.
* Supports `LiveReload` with [LiveReload Chrome Extention](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei).

#### Documents

[https://github.com/SaitoWu/linner/tree/master/docs](https://github.com/SaitoWu/linner/tree/master/docs)

## Requirements

#### *nix

* Ruby 2.0

#### Windows

* Install [Ruby](http://rubyinstaller.org/downloads/) and [DevKit](http://rubyinstaller.org/downloads/)
* Install gem `wdm`
* Install Node.js to make Linner faster

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
