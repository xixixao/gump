chai = require 'chai'
chai.should()

{run} = require '../bin'

{testTasks} = require './util'

{delay} = require 'bluebird'

describe 'run', ->

  it 'should run tasks in series', (done) ->
    value = 0
    run ->
          value = 1
      ,
        ->
          value = 2
    .then ->
      value.should.eql 2
      done()

  it 'should run tasks in parallel and wait for all to finish', (done) ->
    value = 0
    run [
        ->
          delay 100
            .then ->
              if value is 1
                value = 2
      ,
        ->
          value = 1
      ]
    .then ->
      value.should.eql 2
      done()

  it 'should run executed Gump tasks', (done) ->
    value = 0
    testTasks
      tasks:
        a: ->
          value = 1
        b: ->
          run @a()
      run: ['b']
      cb: ->
        value.should.eql 1
      done: done
