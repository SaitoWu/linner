# Linner

Linner is a full-featured HTML5 application assembler.

![Linner](http://d.pr/i/bWPA+)

* Fast!
* Supports `Sass` and `Coffee`.
* Supports OS X Lion and Mountaion Lion Notifications.
* Supports Modular Javascript, All your code will be wrap by `CMD`.
* Supports `concat` code by `config file` not `derective processor`
* Supports `copy` code from `src` to `dist`
* Supports Real-time `concat` by `$ linner watch`
* Supports `compress` by `$ linner build`

## Installation

    $ gem install linner

## Usage

Skeleton:

    $ linner new webapp && cd webapp

Watch:

    $ linner watch

Server:

    $ ./bin/server # or server if put "./bin" in your PATH

Build:

    $ linner build

Clean:

    $ linner clean

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
