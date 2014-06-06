- point out you can pass in arguments
- split serve as separate
- make correct browserify (or find out whether gulp-browserify or faster-browserify works)
- add --save-dev to install all required modules inside gumpfile.coffee
  - make a seperate tool that does this when passed in a glob and whether dev or normal module
- allow to pass in options to gump tasks:
  gump coffee -a -b=123
  coffee = ({a, b}) -> ...
  - we can check whether those options are available, but that is not important

# Gump

**Gump** is the task runner that keeps on running. It watches your files and if you're working on a client-side app, serves and live reloads them automatically, giving you notifications. It's like [Brunch](http://http://brunch.io/) or [Mimosa](http://http://mimosa.io/) - while keeping **you** in full control.

```coffee
{gump, to, pipe, watch, serve} = (require 'gump') require 'gulp'
coffee = require 'gulp-coffee'
stylus = require 'gulp-stylus'
jade = require 'gulp-jade'

all = ->
  watch compiled()
  serve 'bin'

compiled = ->
  pipe js(), css(), templates(),
    -> to 'bin'

js = ->
  pipe 'src|js/**/*.coffee',
    -> coffee()

css = ->
  pipe 'src|css/**/*.styl',
    -> stylus()

templates = ->
  pipe 'src|**/*.jade',
    -> jade()

gump {all}
```

Yes, it's just a nice wrapper for [gulp](http://gulpjs.com/).

## Examples

Full-fledged examples, ready to run:

- [pure CoffeeScript library](https://github.com/xixixao/gump-example-coffee-script-library)
- [CoffeeScript, Jade, Stylus using RequireJS and Bower](https://github.com/xixixao/gump-example-requirejs)
- [CoffeeScript, Jade, Stylus using Browserify and Bower](https://github.com/xixixao/gump-example-browserify)


## Documentation

Piece these together to make up your build.

### Serving

`serve` uses `browser-sync`, just give it the top directory of your app and it will open a browser window with the app running.

```coffee
task 'default', ['js', 'css'], ->
  serve 'bin'
```

### Watching and Live Reload

Whenever you change a sourcefile, `watch` will run the given pipeline only on that file. If you're using `serve` and that file ends up in the served directory the browser will auto reload (or just update in case of images and CSS).

```coffee
watch 'js',
  'src/js/**/*.coffee'
  -> coffee()
  'bin/js'
```

If you don't want to reload the web page when a file is changed, output it outside the served directory.

```coffee
watch 'js',
  'src/js/**/*.coffee'
  -> coffee()
  'build/js'
```

This is useful when you need intermediate files. For example, [Browserify](http://browserify.org/) combines all your Javascript into a single file (I recommend using [RequireJS](http://requirejs.org/) instead). We point `watch` at the main file and the browser will reload only when the whole bundle has finished compiling. **this is broken, seriously, use RequireJS instead**

```coffee
watch 'browserify',
  'build/js/app.js'
  -> browserify()
  'bin/js/'
```

`watch` also automatically fixes errors with [gulp-plumber](https://github.com/floatdrop/gulp-plumber).

### Deleting sources

**Gump** remembers built files and deletes them if you delete the corresponding source.

### Copying

By ommitting any gulp plugins you can simply copy files from one location to another.

```coffee
watch 'lib',
  'src/js/lib/**/*.js'
  'bin/js/lib'
```

### Plain Task

If you don't need to watch the sources, just use a `task`. Notice here that plugin sources work as well.

```coffee
task 'bower',
  -> bower()
  'bin/js/lib'
```

### No Output

If you need more source locations for one task, include them as consecutive arguments (not an array). Options to `gulp.src` can be passed in after the source location. If you don't want to pipe the transformed files anywhere, don't include a destination.

```coffee
task 'clean',
  'build', 'bin', read: false
  -> clean()
```

See the [gulp documentation](https://github.com/gulpjs/gulp) for more details on its API.

Special thanks to @lachenmayer for the initial syntax idea.


### Source Paths

Using globs, but `|` seperates base from the rest.

### gump.pipe

Returns

```coffee
sources: [String]
pipes: [Function]
```

