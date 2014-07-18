gulp = require 'gulp'

gump = require '../bin'
gumpTasks = gump.tasks

exports.testTasks = ({tasks, cb, run, done})->
  gump.setGulp gulp = new gulp.Gulp
  gumpTasks tasks
  gulp.on 'stop', ->
    cb?()
    done()
  gulp.start run...
