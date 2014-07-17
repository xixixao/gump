path = require 'path'

gulp = require 'gulp'
cache = require 'gulp-cached'
notify = require 'gulp-notify'
filter = require 'gulp-filter'
plumber = require 'gulp-plumber'
clean = require 'gulp-clean'

combine = require 'ordered-read-streams'
once = require 'once'
subdir = require 'subdir'
browserSync = require 'browser-sync'
asyncDone = require 'async-done'
async = require 'async'
{promisify} = require 'bluebird'
map = require 'vinyl-map'
unique = require 'unique-stream'

{reportWrongUseOfWatch, catchGumpErrors} = require './errors'
{parseArguments} = require './argumentparsing'
{globsToStream} = require './globbing'

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
  for own name, taskFn of tasksDefinition
    do (name, taskFn) ->
      tasksDefinition[name] = task = (args...) ->
        new Task name, (done) -> taskFn args..., done
      gulp.task name, ->
        run task()
  gulp

exports.pipe = (args...) ->
  globs = []
  sources = []
  mutators = []
  for arg in args
    if arg in tasks
      sources.push arg()
    else if arg instanceof Task
      sources.push arg
    else if typeof arg is 'string'
      globs.push arg
    else
      mutators.push arg
  sources.push globsToStream globs
  new Pipe sources, mutators

class Task
  constructor: (@name, @body) ->

class Pipe
  constructor: (@sources, @mutators) ->
  run: (cb) ->
    stream = combine @sources
    stream = stream.pipe unique 'path'
    stream = stream.pipe step() for step in @mutators
    asyncDone (-> stream), cb

runSingle = (arg) ->
  if arg instanceof Task
    (cb) -> asyncDone.sync arg.body, (err, result) ->
      if result instanceof Pipe
        result.run cb
      else
        cb err, result
  else if arg instanceof Pipe
    (cb) -> arg.run cb
  else
    (cb) ->
      asyncDone.sync arg, cb

exports.run = run = (args...) ->
  tasks = for arg in args
    if Array.isArray arg
      (cb) -> async.parallel arg.map(runSingle), cb
    else
      runSingle(arg)
  promisify(async.series) tasks

exports.to = gulp.dest