{tasks, to, pipe, watch, serve} = require '../../bin'
coffee = require 'gulp-coffee'
stylus = require 'gulp-stylus'
jade = require 'gulp-jade'

tasks

  default: ->
    console.log "hello"
    # watch @compiled
    # serve 'bin'

  compiled: ->
    pipe @js, @css, @templates,
      -> to 'bin'

  js: ->
    pipe 'src|js/**/*.coffee',
      -> coffee()

  css: ->
    pipe 'src|css/**/*.styl',
      -> stylus()

  templates: ->
    pipe 'src|**/*.jade',
      -> jade()

  clean: ->
    rmrf 'bin'
