chai = require 'chai'
chai.should()

{parseArguments, GumpError} = require '../bin/argumentparsing'

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

    it 'should work without a callback with some dependencies', ->
      {name, deps} = parseArguments [
        'hello'
        ['a']
      ]
      name.should.eql 'hello'
      deps.should.eql ['a']

    it 'should not work without no callback and no dependencies', ->
      fn = -> parseArguments [
        'hello'
      ]
      fn.should.throw GumpError

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

    it 'should accept options to gulp.src', ->
      {name, srcs, dest} = parseArguments [
        'hello'
        'from1', 'from2', read: no
        'to'
      ]
      name.should.eql 'hello'
      srcs.should.eql ['from1', 'from2']
      dest.should.eql 'to'

    it 'should allow no dest if there is a pipe', ->
      {name, srcs, dest} = parseArguments [
        'hello'
        'from'
        (pipe = -> )
      ]
      name.should.eql 'hello'
      srcs.should.eql ['from']
      chai.expect(dest).to.not.exist

    it 'should allow no dest and stream as a source', ->
      {name, src, pipes, dest} = parseArguments [
        'hello'
        (source = -> )
        (pipe = -> )
      ]
      name.should.eql 'hello'
      console.log pipes
      src.should.equal source
      pipes.should.eql [pipe]
      chai.expect(dest).to.not.exist

    it 'should not accept succint style without a source', ->
      fn = -> parseArguments [
        'hello'
        'dest'
      ]
      fn.should.throw GumpError
