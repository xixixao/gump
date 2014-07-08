path = require 'path'

gulp = require 'gulp'
cache = require 'gulp-cached'
notify = require 'gulp-notify'
filter = require 'gulp-filter'
plumber = require 'gulp-plumber'
clean = require 'gulp-clean'

once = require 'once'
subdir = require 'subdir'
browserSync = require 'browser-sync'
asyncDone = require 'async-done'
async = require 'async'
Promise = require 'bluebird'

{reportWrongUseOfWatch, catchGumpErrors} = require './errors'
{parseArguments} = require './argumentparsing'

map = (fn) ->
  filter (file) ->
    fn file
    true

pipe = (stream, pipes, dest) ->
  stream = stream.pipe step() for step in pipes
  stream = stream.pipe gulp.dest dest if dest
  stream

exports.task = (args...) -> catchGumpErrors ->
  {name, deps, callback, src, pipes, dest} = parseArguments args
  gulp.task name, deps, callback or -> pipe src(), pipes, dest

serving = undefined

shouldServe = (file) ->
  subdir serving.dir, file.path if serving?

livereload = (file) ->
  serving.instance.changeFile file.path,
    injectFileTypes: ['css', 'png', 'jpg', 'jpeg', 'svg', 'gif', 'webp']
  true

reloadIfServed = (stream, message) ->
  stream
    .pipe filter shouldServe
    .pipe notify "#{message} <%= file.relative %>"
    .pipe filter livereload

mark = (file) ->
  file.__original = file.path

memory = {}

rememberMarked = (file) ->
  memory[file.__original] = file.path

handleDeletion = ({type, path}) ->
  if type is 'deleted'
    stream = gulp.src memory[path]
      .pipe clean()
    reloadIfServed stream, 'Deleted'

exports.watch = (args...) -> catchGumpErrors ->
  {name, deps, callback, src, srcs, pipes, dest} = parseArguments args
  reportWrongUseOfWatch name if callback
  gulp.task name, deps, ->
    do once ->
      gulp.watch srcs, [name]
      .on 'change', handleDeletion
    stream = src()
      .pipe cache name
      .pipe plumber()
      .pipe map mark
    stream = pipe stream, pipes, dest
      .pipe map rememberMarked
    reloadIfServed stream, 'Compiled'

exports.serve = (baseDir = './') -> catchGumpErrors ->
  serving =
    dir: baseDir
    instance: browserSync.init [],
      server: {baseDir}
      notify: false

tasks = {}

exports.tasks = (tasksDefinition) ->
  tasks = tasksDefinition
  for own name, task of tasksDefinition
    do (name, task) ->
      tasksDefinition[name] = (args...) ->
        new Task name, task args...
  for own name, task of tasksDefinition
    do (name, task) ->
      gulp.task name, ->
        run task()

exports.pipe = (args...) ->
  sources = []
  mutators = []
  for arg in args
    if arg in tasksDefinition
      sources.push arg()
    else if arg instanceof Task
      sources.push arg
    else if typeof arg is 'string'
      sources.push glob arg
    else
      mutators.push arg
  new Pipe sources, mutators

exports.Task = class Task
  constructor: (@name, @body) ->

exports.Pipe = class Pipe
  constructor: (@sources, @mutators) ->
  run: (cb) ->
    stream = combine @sources
    stream = stream.pipe @mutators() for step in pipes
    asyncDone (-> stream), cb

exports.run = run = (args...) ->
  tasks = for arg in args
    if Array.isArray arg
      (cb) -> async.parallel arg, cb
    else if arg instanceof Task
      (cb) -> asyncDone arg.body, (err, result) ->
        if result instanceof Pipe
          result.run cb
        else
          cb err, result
    else if arg instanceof Pipe
      (cb) -> arg.run cb
  Promise.promisify(async.series) tasks

exports.to = gulp.dest