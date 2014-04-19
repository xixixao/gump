path = require 'path'

gulp = require 'gulp'
cache = require 'gulp-cached'
notify = require 'gulp-notify'
filter = require 'gulp-filter'

once = require 'once'
subdir = require 'subdir'
browserSync = require 'browser-sync'

{reportWrongUseOfWatch, catchGumpErrors} = require './errors'
{parseArguments} = require './argumentparsing'

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

exports.watch = (args...) -> catchGumpErrors ->
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

exports.serve = (baseDir = './') -> catchGumpErrors ->
  serving =
    dir: baseDir
    instance: browserSync.init [],
      server: {baseDir}
      notify: false

