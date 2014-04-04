# Gump

Gump is the task runner that keeps on running. It watches your files and if you're working on a client-side app, serves and live reloads them automatically, giving you notifications. It's like Brunch or Mimosa - while keeping **you** in full control.

```coffee
{task, watch, serve} = require 'gump'
coffee = require 'gulp-coffee'
stylus = require 'gulp-stylus'
jade = require 'gulp-jade'

task 'default', [
  'js'
  'css'
  'templates'
], ->
  serve 'bin'

watch 'js',
  'src/js/**/*.coffee'
  -> coffee()
  'bin/js'
  '**/*.js'

watch 'css',
  'src/css/**/*.styl'
  -> stylus()
  'bin/css'
  '**/*.css'

watch 'templates',
  'src/**/*.jade'
  -> jade()
  'bin'
  '**/*.html'
```

Yes, it's just a nice wrapper for [gulp](http://gulpjs.com/).

## More examples

Full-fledged examples, ready to run:

- [pure CoffeeScript library]
- [CS, Jade, Stylus using Browserify and Bower]
- [CS, Jade, Stylus using RequireJS and Bower]

Piece these together to make up your build:

---

`serve` uses `browser-sync`, just give it the top directory of your app and it will open a browser window with the app running.

```coffee
task 'default', ['js', 'css'], ->
  serve 'bin'
```

---

`watch` needs as a last argument the *glob* to match files in the destination directory which should trigger live reload. There is no way to guess this from the rest of the arguments. Here we convert *CommonJS* syntax CoffeeScript files to *RequireJS* ready modules.

```coffee
watch 'js',
  'src/js/**/*.coffee'
  -> coffee bare: true
  -> commonJsToRequireJs()
  'bin/js'
  '**/*.js'
```


---

If you don't want to reload the web page when a file is changed, use `no` instead of a *glob*.

```coffee
watch 'js',
  'src/js/**/*.coffee'
  -> coffee()
  'build/js'
  no
```

You should probably use RequireJS, but if you want *Browserify*, we need to have intermediate files. *Browserify* combines them for us and we tell `watch` to reload the browser only when the whole bundle is finished compiling.

```coffee
watch 'browserify',
  'build/js/app.js'
  -> browserify()
  'bin/js/'
  'app.js'
```

---

By ommitting any gulp plugins you can simply copy files from one location to another.

```coffee
watch 'lib',
  'src/js/lib/**/*.js'
  'bin/js/lib'
  '**/*.js'
```

---

If you don't need to watch the sources, just use a `task`. Notice here that plugin sources work as well. We use `flatten` to get rid of bower package paths and get a simple list of script files.

```coffee
task 'bower',
  -> bower()
  -> flatten()
  'bin/js/lib'
```

---

If you don't have a destination, include an empty string as the last argument to task (otherwise **Gump** couldn't tell between callback style and succint style call).

```coffee
task 'clean',
  'bin'
  -> rm read: false
  ''
```

See the [gulp documentation] for more details on its API.

Special thanks to @lachenmayer for the initial syntax idea.
