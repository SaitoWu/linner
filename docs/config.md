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

`compile` defines compile strategy of files in Linner. The `Dir.glob` of `value` will be compile to `key` folder.

`precompile` defines precompile strategy of javascript templates for Linner. The `Dir.glob` of `value` will be concat to `key`.

`sprite` defines sprite strategy of images for Linner. The `Dir.glob` of `value` will be sprite to `key`.

`tar` defines archive strategy of files in Linner. The `Dir.glob` of `value` will be archive to `key` file.

`context` defines the context of the `compile` files, and the value will pass to the render function.

`order` defines the order of this group files, and It's very useful when you `concat` your files. for example:

```yaml
order:
  - "vendor/jquery-1.10.2.js"
  - "..."
  - "vendor/underscore.js"
```

In the above example, if a group contains 5 files, `vendor/jquery-1.10.2.js` will be the first, and `vendor/underscore.js` will be the last file.

## `sprites`

`sprites` defines application sprite stategy. `sprites` support pseudo class of css, if your file's basename end with `_active`, the generated css will be `.active`. if your file's basename end with `_hover`, the generated css will be `:hover`, eg: `arrow_hover.png` will be `.selector-arrow:hover { ... }`

Example:

```yaml
sprites:
  # sprite image output path
  path: "/images/"
  # css selector
  selector: ".icon-"
```

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
revision:
  prefix: "/public"
  cdn: http://assets.yoursite.com
  manifest: "manifest.yml"
  files:
    - "index.html"
```

the `prefix` will join with revision hashes.

the `cdn` will also join with revision hashes, so it will be like `http://assets.yoursite.com/public/assets/scripts/app.js`.

the `manifest` will join with `public` folder, write a manifest file with the name.

`index.html` will join with `public` folder. So, by default when you `build` your application, the `public/index.html` file will be rewrote with revision.



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
    version: 1.10.2
    url: http://code.jquery.com/jquery-1.10.2.js
  underscore.js:
    version: 1.5.2
    url: https://raw.github.com/jashkenas/underscore/1.5.2/underscore.js
  backbone.js:
    version: 1.1.0
    url: https://raw.github.com/jashkenas/backbone/1.1.0/backbone.js
  handlebars.js:
    version: 1.0.0
    url: https://raw.github.com/wycats/handlebars.js/1.0.0/dist/handlebars.js
```

bundles also supports `tar.gz` file on the internet, you should give it a try.

When you use `tar.gz` file, the key of bundle can be a folder name, all the archived files will be decompression to the folder.


## `environments`

`environments` defines application's running environment config, the default environment is `development`.

If you use `linner build` to build your webapp, the environment would be `production`.

For example:

```yaml
environments:
  staging:
    revision:
      cdn: http://staging.yoursite.com
  production:
    revision:
      cdn: http://production.yoursite.com
```

You can use `linner build -e staging` to use the staging environment's variables.

When you use `linner watch` to watch the project, it's equals to `linner watch -e development`, and the `development` environment is the default environment, you don't need to write it.

When you use `linner build` to build the project, it's equals to `linner build -e produciton`.
