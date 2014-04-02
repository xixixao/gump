# Gump

Gump is the task runner that keeps on running. It watches your files and if you're working on an app, serves and live reloads automatically, giving you notifications. It's like Brunch or Mimosa - while keeping **you** in full control.

```coffee
{task, watch, serve} = require 'gump'
coffee = require 'gulp-coffee'
stylus = require 'gulp-stylus'
jade = require 'gulp-jade'

task 'default', [
  'js'
  'lib'
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

Full-fledged example, ready to run:

- [CoffeeScript library]
- [CS, Jade, Stylus using Browserify and Bower]
- [CS, Jade, Stylus using RequireJS and Bower]

Piece these together to make up your build:

---

`serve` uses `browser-sync`, just give it the top directory of your app.

```coffee
task 'default', ['js', 'css'], ->
  serve 'bin'
```

---

`watch` needs as a last argument the *glob* to match files in the destination directory which should trigger live reload. There is no way to guess this from the rest of the arguments. Here we convert *CommonJS* syntax CoffeeScript files to *RequireJS* ready modules.

watch 'js',
  'src/js/**/*.coffee'
  -> coffee bare: true
  -> commonJsToRequireJs()
  'bin/js'
  '**/*.js'



---

If you don't want to reload the web page when a file is changed, use `no` instead of a *glob*.

watch 'js',
  'src/js/**/*.coffee'
  -> coffee()
  'build/js'
  no

You should probably use RequireJS, but if you want *Browserify*, we need to have intermediate files. *Browserify* combines them for us and we tell watch to reload the browser only when the whole bundle is finished compiling.

watch 'browserify',
  'build/js/app.js'
  -> browserify()
  'bin/js/'
  'app.js'

---

By ommitting any gulp plugins you can simply copy files from one location to another.

watch 'lib',
  'src/js/lib/**/*.js'
  'bin/js/lib'
  '**/*.js'

---

If you don't need to watch the sources, just use a `task`. Notice here that plugin sources work as well. We use `flatten` to get rid of bower package paths and get a simple list of script files.

task 'bower',
  -> bower()
  -> flatten()
  'bin/js/lib'

---

If you don't have a destination, include an empty string as the last argument to task (otherwise **Gump** couldn't tell between callback style and succint style call).

task 'clean',
  'bin'
  -> rm read: false
  ''

Special thanks to @lachenmayer for the initial syntax idea.
