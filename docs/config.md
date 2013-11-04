# Configuration file

Linner use `config.yml` file to config your application.

## `paths`

`paths` defines application paths, it contains `app`, `test`, `vendor` and `public` folders.

Default:

```yaml
paths:
  app: "app"
  test: "test"
  vendor: "vendor"
  public: "public"
```

`linner watch` command will watch `app`, `test` and `vendor` folders, and the builded file will be in `public` folder.

## `groups`

`groups` defines application groups, you can define any type of groups in it.

Default:

```yaml
groups:
  scripts:
    paths:
      - "app/scripts"
    order:
      - "vendor/jquery-1.10.2.js"
      - "..."
  styles:
    paths:
      - "app/styles"
  images:
    paths:
      - "app/images"
  views:
    paths:
      - "app/views"
```

the default configuration defines four groups: `scripts`, `styles`, `images` and `views` group.

`paths` defines where can linner find this group's files, It's a `Array`.

`concat` defines concatenation of files in Linner. the `Dir.glob` of `value` will be concat to `key` file.

`copy` defines copy strategy of files in Linner. The `Dir.glob` of `value` will be copy to `key` folder.

`precompile` defines precompile strategy of javascript templates for Linner. The `Dir.glob` of `value` will be concat to `key`

`order` defines the order of this group files, and It's very useful when you `concat` your files. for example:

```yaml
order:
  - "vendor/jquery-1.10.2.js"
  - "..."
  - "vendor/underscore.js"
```

In the above example, if a group contains 5 files, `vendor/jquery-1.10.2.js` will be the first, and `vendor/underscore.js` will be the last file.

## `modules`

`modules` defines application module strategy, The default wrapper is `cmd`.

Default:

```yaml
modules:
  wrapper: "cmd"
  ignored: "vendor/**/*"
  definition: "scripts/app.js"
```

All of your code will be wrapped by `cmd`(Common Module Definition) except `ignored` glob pattern.

The definition file will prepend to `definition` field, which will join with `public` folder.

## `revision`

`revision` defines application layout page, which contains `link` and `script` tags.

Default:

```yaml
revision: "index.html"
```

`index.html` will join with `public` folder. So, by default when you `build` your application, the `public/index.html` file will be rewrited with revision.

If you don't need `revision` support, it can be `false`.

## `notification`

`notification` defines application error notification.

Default:

```yaml
notification: true
```

## `bundles`

`bundles` defines application's library dependencies, the dependencies will be copied to `vendor` folder.

For example:

```yaml
bundles:
  jquery.js:
    version: "1.10.2"
    url: "http://code.jquery.com/jquery-1.10.2.js"
  underscore.js:
    version: "1.5.2"
    url: https://raw.github.com/jashkenas/underscore/1.5.2/underscore.js
  backbone.js:
    version: "1.1.0"
    url: "https://raw.github.com/jashkenas/backbone/1.1.0/backbone.js"
  handlebars.js:
    version: "1.0.0"
    url: "https://raw.github.com/wycats/handlebars.js/1.0.0/dist/handlebars.js"
```
