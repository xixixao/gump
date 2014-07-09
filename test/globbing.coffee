chai = require 'chai'
chai.should()

{pipe} = require '../bin'
path = require 'path'
map = require 'vinyl-map'
glob = require 'glob'
gulp = require 'gulp'

describe 'globbing', ->
  it 'should work with standard glob', (done) ->
    pipe 'test/fixtures/*.srb',
      -> map (content, fileName) ->
        path.basename(fileName).should.eql 'a.srb'
        done()
    .run ->
