gulp = require 'gulp'

{reportMissingSource, reportMissingStyle} = './errors'

# Rules for arguments to `task` and `watch`
# @required String |name|
# @optional Array |dependent tasks|
# either
#     @required Function |callback|
#   or
#     either
#         @required String... |sources|
#         @optional Object |options|
#       or
#         @required Function |source|
#     @optional Function... |pipes|     -\ ________________
#     @optional String |destination|    _/ at least 1 given

gulpSrcForArgs = (args) ->
  srcs = []
  while args.length > 0 and typeof args[0] is 'string'
    srcs.push args[0]
    args = args[1..]
  if args.length > 0
    [potentialOpts] = args
    if potentialOpts and typeof potentialOpts not in ['function', 'string']
      opts = potentialOpts
      args = args[1..]
  [(-> gulp.src srcs, opts), srcs, args]

exports.parseArguments = ([name, args...]) ->
  if args.length > 0
    [potentialDeps] = args
    if Array.isArray potentialDeps
      deps = potentialDeps
      args = args[1..]
  reportMissingStyle if args.length < 1
  [args..., lastArg] = args
  if args.length == 0
    callback = lastArg
  else
    dest = lastArg
    reportMissingSource name if args.length < 1
    [src] = args
    if typeof src is 'function'
      pipes = args[1..]
    else
      [src, srcs, pipes] = gulpSrcForArgs args
  {name, deps, callback, src, srcs, pipes, dest}
