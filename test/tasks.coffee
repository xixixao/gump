chai = require 'chai'
chai.should()

{tasks} = require '../bin'

{delay} = require 'bluebird'

describe 'tasks', ->

  it 'should register tasks as gulp tasks', (done) ->
    gulp = tasks
      some: ->
        "whatever"

    gulp.once 'stop', (event) ->
      done()
    gulp.start ['some']

  it 'should wait for a promise to finish', (done) ->
    temp = no
    gulp = tasks
      some: ->
        delay 100
          .then ->
            temp = yes

    gulp.once 'stop', (event) ->
      temp.should.eql yes
      done()
    gulp.start ['some']

