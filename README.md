# Gump

**Gump** is a task runner and a build file tool based on [gulp](http://gulpjs.com/).

```coffee
{pipe, to, run, watch} = require 'gump'
serve = require 'gump-serve'

coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
imagemin = require 'gulp-imagemin'
rimraf = require 'rimraf'

tasks
  # The default task (called when you run `gulp` from cli)
  default: ->
    run @clean,
      @assets
      # Rerun the task when a file changes
      # Serve the build directory
      [serve('build'), watch(@assets)]

  assets: ->
    pipe @scripts, @images,
      -> to 'build'

  scripts: ->
    # Minify and copy all JavaScript (except vendor scripts)
    pipe 'client|js/**/*.coffee', '!client/js/external/**/*.coffee',
      -> coffee()
      -> uglify()
      -> concat 'all.min.js'

  # Copy all static images
  images: ->
    pipe 'client|img/**/*',
      # Pass in options to the plugin
      -> imagemin optimizationLevel: 5

  clean: ->
    rimraf 'build'
```


## Walkthrough

With Gump, you define tasks in an object literal passed into **tasks**.
```coffee
{tasks} = require 'gump'

tasks
  default: ->
    # task definition
  clean: ->
    # ...
```

Task definitions are just ordinary functions, and you can do anything you want inside of them. If the task includes asynchronous code, you should make sure that Gump can find out when the task is done.

```coffee
tasks
  # synchronous
  clean: ->
    rimraf 'bin'
  # returning a Promise
  api: ->
    promisify(apiCall) 'www.test.com'
  # calling @done
  test: ->
    fs.readFile 'test', (err, contents) =>
      console.log contents
      @done err
```

Most of the time though, you will want to handle files inside your tasks. Gump provides an easy way to manipulate files. First, you match files using Globs. Globs are strings representing file paths with expansions similar to bash.

```coffee
'src/**/*.coffee'
```

`**` stands for arbitrary path, `*` for arbitrary substring of a file name. You can also give specific options.

```coffee
'src/{main,lib}.coffee'
```

Globs in Gump add one special syntax, the base path separator.

```coffee
'src|style/**/*.css'
```

If you were to copy the file `src/style/main.css` matched by this glob into the `compiled` directory, the resulting file path would be `compiled/style/main.css`. You can also create negative Globs, which will prevent files to be matched, by placing `!` at the start of the string

```coffee
'!src/lib/**'
```

Globs are used to create Streams. Streams carry a set of files, which can be modified (both in contents and location) and written back to the file system. In Gump, you use the **pipe** function to create Streams.

```coffee
{pipe, to} = require 'gump'

    pipe 'src|*.coffee',
      -> to 'bin'
```

This call to **pipe** creates a Stream of files matching the Glob and copies them to the `bin` directory. Streams are passed through Modifiers, functions which return an instance of some gulp plugin.

```coffee
coffee = require 'gulp-coffee'
minify = require 'gulp-minify'

    pipe 'src|*.coffee',
      -> coffee bare: true
      -> minify()
      -> to 'minified'
```

**to** itself is just a gulp plugin, one which writes files to the disk. **pipe** accepts arbitrary number of sources, including other Streams, and combines them into a single Stream. This way, you can compose tasks which are made of Streams.

```coffee
tasks
  js: ->###put this at the end###
    pipe 'src|*.coffee',
      -> coffee()
  minJs: ->
    pipe @js(),
      -> minify()
      -> to 'minified'
  testJs: ->
    pipe @js(),
      -> to 'test'
```

**pipe** can figure out that you passed in a task, so you don't have to call the task if it doesn't accept any arguments.

```coffee
  minJs: ->
    pipe @js,
      -> to 'minimized'
```

But tasks *can* take arguments, which lets you customize them in different ways.  You can pass different arguments to Modifiers, different Modifiers or sources to **pipe**.

```coffee
header = require 'gulp-header'

  default: ->
    pipe @header(@js, @ls, '1.8')
  header: (compiled..., version) ->
    pipe compiled...,
      -> header "Lang #{version}"
```

Gump is also a task runner, and as such provides a mechanism for scheduling tasks via the **run** function.

```coffee
{run} = require 'gump'

  default: ->
    run @clean(),
      @build()
      @build()
      @test()
```

Most of the time, you will simply combine streams, but for times when this is not possible, **run** can be useful. You can also run tasks in parallel, and similarly with **pipe**, you don't have to call the tasks.

```coffee
  default: ->
    run @build,
      [@lint, @test]
      @deploy
```

Here is an example gulpfile which includes all the mentioned features.

## Beyond Gump - Work in Progress below

You can create support tasks which will not be callable from the command line, to make the API clearer.

```coffee
tasks
  default: ->
    run [@js, @css]
support
  js: ->
  css: ->
```

gump-watch, gump-serve

## Design

**run** doesn't allow nested parallel sets, to discourage unreadable execution patterns.

In general, you should keep the **run** calls simple. If you need to run many tasks in parallel in the middle of a series, its better to decompose them.

default: ->
  run @compile,
    @check
    @deploy
check: ->
  run [
    @test
    @lint
    @hint
    @travis

]
