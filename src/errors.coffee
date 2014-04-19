gutil = require 'gutil'

exports.reportMissingSource = (name) ->
  {red, cyan} = gutil.colors
  gutil.log red '[Gump Fatal Error]',
      red 'Succint style used for a'
      cyan 'task'
      red 'called'
      name
      red 'but missing a source!'
  throw new gutil.PluginError 'Gump', 'missing source'

exports.reportMissingStyle = (name) ->
  {red, cyan} = gutil.colors
  gutil.log red '[Gump Fatal Error]',
      red 'Missing additional arguments for'
      cyan 'task'
      red 'called'
      name
  throw new gutil.PluginError 'Gump', 'missing source'

exports.reportWrongUseOfWatch = (name) ->
  {red} = gutil.colors
  gutil.log red '[Gump Fatal Error]',
      cyan 'watch'
      name
      red 'requires succint style, but callback given',
  throw new gutil.PluginError 'Gump', 'wrong style for watch'
