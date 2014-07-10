chai = require 'chai'
chai.should()

{pipe} = require '../bin'
path = require 'path'
mapStream = require 'map-stream'
glob = require 'glob'
gulp = require 'gulp'

map = (mapper) ->
  mapStream (data, cb) ->
    cb null, mapper data

testBy = (tester) -> (globs, basenames) -> (done) ->
  actuals = []
  pipe globs...,
    -> map (file) ->
      actuals.push tester file
  .run ->
    actuals.should.eql basenames
    done()

testNames = testBy (file) -> path.basename file.path

testBases = testBy (file) -> file.base

describe 'globbing', ->
  it 'should work with standard positive glob',
    testNames ['test/fixtures/**/a.srb'], ['a.srb']

  it 'should work with standard negative glob',
    testNames ['test/fixtures/*.srb', '!test/fixtures/b.srb'], ['a.srb']

  it 'should set base path correctly on single glob',
    testBases ['test|fixtures/a.srb'], ['test']

  it 'should set base path correctly on multiple globs',
    testBases ['test|fixtures/a.srb', 'test/fixtures|b.srb'],
      ['test', 'test/fixtures']

  it 'should work with negative options',
    testNames ['test/fixtures/{!b}.srb'], ['a.srb']

  it 'should include parent dir when no string negative is used',
    testNames ['test/fixtures/{!!c}/*.srb'], ['a.srb', 'b.srb', 'd.srb']
