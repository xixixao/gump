chai = require 'chai'
chai.should()

{tasks} = require '../bin'

describe 'tasks', ->
  it 'should register tasks as gulp tasks', (done) ->
    gulp = tasks
      some: ->
        console.log "Hello world!"

    gulp.on 'stop', -> done()
    gulp.start ['some']

