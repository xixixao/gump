gutil = require 'gulp-util'

# For testing
exports.GumpError = class GumpError extends Error
  # required for instanceof to work
  constructor: (message, @log) -> super message

exports.reportMissingSource = (name) ->
  {red, cyan} = gutil.colors
  throw new GumpError 'Gump Error: missing source', ->
    gutil.log red '[Gump Fatal Error]',
      red 'Succinct style used for'
      cyan name
      red 'but missing a source glob!'

exports.reportMissingStyle = (name) ->
  {red, cyan} = gutil.colors
  throw new GumpError 'Gump Error: missing arguments', ->
    gutil.log red '[Gump Fatal Error]',
      red 'Missing additional arguments for'
      cyan name

exports.reportWrongUseOfWatch = (name) ->
  {red, cyan} = gutil.colors
  throw new GumpError 'Gump Error: wrong arguments', ->
    gutil.log red '[Gump Fatal Error]',
      red 'Watching'
      cyan name
      red 'requires succinct style, but callback given',

exports.catchGumpErrors = (fn) ->
  try
    fn()
  catch error
    if error instanceof GumpError
      error.log()
    else
      throw error
  return
