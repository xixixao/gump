chai = require 'chai'
chai.should()

{parseArguments} = require '../bin/argumentparsing'

describe 'argument parsing', ->

  describe 'callback style', ->

    it 'should accept full arguments', ->
      {name, deps, callback} = parseArguments [
        'hello'
        ['a', 'b']
        fn = ->
      ]
      name.should.eql 'hello'
      deps.should.eql ['a', 'b']
      callback.should.equal fn

    it 'should accept callback without dependencies', ->
      {name, callback} = parseArguments [
        'hello'
        fn = ->
      ]
      name.should.eql 'hello'
      callback.should.equal fn

  describe 'succint style', ->

    it 'should accept single source and destination', ->
      {name, srcs, dest} = parseArguments [
        'hello'
        'from'
        'to'
      ]
      name.should.eql 'hello'
      srcs.should.eql ['from']
      dest.should.eql 'to'

    it 'should accept multiple sources', ->
      {name, srcs, dest} = parseArguments [
        'hello'
        'from1', 'from2'
        'to'
      ]
      name.should.eql 'hello'
      srcs.should.eql ['from1', 'from2']
      dest.should.eql 'to'

    it 'should accept options to gulp.src', ->
      {name, srcs, dest} = parseArguments [
        'hello'
        'from1', 'from2', read: no
        'to'
      ]
      name.should.eql 'hello'
      srcs.should.eql ['from1', 'from2']
      dest.should.eql 'to'

    it 'should accept null as valid dest if there is a pipe', ->
      {name, srcs, pipes, dest} = parseArguments [
        'hello'
        'from'
        (pipe = -> )
        null
      ]
      name.should.eql 'hello'
      srcs.should.eql ['from']
      pipes.should.eql [pipe]
      chai.expect(dest).to.equal null

