path = require 'path'

gulp = require 'gulp'
cache = require 'gulp-cached'
notify = require 'gulp-notify'
filter = require 'gulp-filter'

once = require 'once'
subdir = require 'subdir'
browserSync = require 'browser-sync'

serving = undefined

source = (src) ->
  switch
    when typeof src is 'string' or Array.isArray src then gulp.src src
    when typeof src is 'function' then src()
    else src

pipe = (stream, pipes, dest) ->
  stream = stream.pipe step() for step in pipes
  stream = stream.pipe gulp.dest dest if dest isnt ''
  stream

exports.task = (name, src, pipes..., dest) ->
  if dest? and typeof dest is 'string'
    gulp.task name, ->
      pipe source(src), pipes, dest
  else
    gulp.task name, src, dest

shouldServe = (file) ->
  subdir serving.dir, file.path if serving?

livereload = (file) ->
  serving.instance.changeFile file.path,
    injectFileTypes: ['css', 'png', 'jpg', 'jpeg', 'svg', 'gif', 'webp']
  true

exports.watch = (name, src, pipes..., dest) ->
  gulp.task name, ->
    do once ->
      gulp.watch src, [name]
    stream = source src
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

