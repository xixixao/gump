chai = require 'chai'
chai.should()

{run} = require '../bin'

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
