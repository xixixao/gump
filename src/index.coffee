path = require 'path'

gulp = require 'gulp'
cache = require 'gulp-cached'
notify = require 'gulp-notify'
filter = require 'gulp-filter'

once = require 'once'
subdir = require 'subdir'
browserSync = require 'browser-sync'

# Rules for arguments to task and watch
# @required String |name|
# @optional Array |dependent tasks|
# either
#     @required Function |callback|   # not allowed for watch
#   or
#     either
#         @required String... |sources|
#         @optional Object |options|
#       or
#         @required Function |source|
#     @optional Function... |pipes|
#     @required String|null |destination|

reportMissingSource = (name) ->
  {red, cyan} = gutil.colors
  gutil.log red '[Gump Fatal Error]',
      red 'Succint style used for a'
      cyan 'task'
      red 'called'
      name
      red 'but missing a source!'
  throw new gutil.PluginError 'Gump', 'missing source'

reportWrongUseOfWatch = (name) ->
  {red} = gutil.colors
  gutil.log red '[Gump Fatal Error]',
      cyan 'watch'
      name
      red 'requires succint style, but callback given',
  throw new gutil.PluginError 'Gump', 'wrong style for watch'

gulpSrcForArgs = (args) ->
  srcs = []
  while args.length > 0 and typeof args[0] is 'string'
    srcs.push args[0]
    args = args[1..]
  if args.length > 0
    [potentialOpts] = args
    if potentialOpts and typeof potentialOpts not in ['function', 'string']
      opts = potentialOpts
      args = args[1..]
  [(-> gulp.src srcs, opts), srcs, args]

parseArguments = ([name, args..., lastArg]) ->
  if args.length > 0
    [potentialDeps] = args
    if Array.isArray potentialDeps
      deps = potentialDeps
      args = args[1..]
  if not lastArg or typeof lastArg is 'string'
    dest = lastArg
    reportMissingSource name if args.length < 1
    [src] = args
    if typeof src is 'function'
      pipes = args[1..]
    else
      [src, srcs, pipes] = gulpSrcForArgs args
  else
    callback = lastArg
  {name, deps, callback, src, srcs, pipes, dest}

pipe = (stream, pipes, dest) ->
  stream = stream.pipe step() for step in pipes
  stream = stream.pipe gulp.dest dest if dest
  stream

exports.task = (args...) ->
  {name, deps, callback, src, pipes, dest} = parseArguments args
  gulp.task name, deps, callback or -> pipe src(), pipes, dest

serving = undefined

shouldServe = (file) ->
  subdir serving.dir, file.path if serving?

livereload = (file) ->
  serving.instance.changeFile file.path,
    injectFileTypes: ['css', 'png', 'jpg', 'jpeg', 'svg', 'gif', 'webp']
  true

exports.watch = (args...) ->
  {name, deps, callback, src, srcs, pipes, dest} = parseArguments args
  reportWrongUseOfWatch name if callback
  gulp.task name, deps, ->
    do once ->
      gulp.watch srcs, [name]
    stream = src()
      .pipe cache name
    pipe stream, pipes, dest
    .pipe filter shouldServe
    .pipe notify 'Compiled <%= file.relative %>'
    .pipe filter livereload

exports.serve = (baseDir = './') ->
  serving =
    dir: baseDir
    instance: browserSync.init [],
      server: {baseDir}
      notify: false

