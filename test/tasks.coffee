chai = require 'chai'
chai.should()

{testTasks} = require './util'

{delay} = require 'bluebird'

describe 'tasks', ->

  it 'should register tasks as gulp tasks', (done) ->
    testTasks
      tasks:
        some: ->
          "whatever"
      run: ['some']
      done: done

  it 'should wait for a promise to finish', (done) ->
    temp = no
    testTasks
      tasks:
        some: ->
          delay 100
            .then ->
              temp = yes
      cb: ->
        temp.should.eql yes
      run: ['some']
      done: done

