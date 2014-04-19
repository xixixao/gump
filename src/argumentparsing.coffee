gulp = require 'gulp'

{reportMissingSource, reportMissingStyle} = require './errors'

# Rules for arguments to `task` and `watch`
# @required String |name|
# @optional Array |dependent tasks|    -\_________________
# either                               -/ at least 1 given
#     @optional Function |callback|
#   or
#     either
#         @required String... |sources|
#         @optional Object |options|
#       or
#         @required Function |source|
#     @optional Function... |pipes|     -\_________________
#     @optional String |destination|    -/ at least 1 given

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
  reportMissingStyle name unless deps? or args.length > 0
  [..., lastArg] = args
  if args.length <= 1 and (not lastArg or typeof lastArg is 'function')
    callback = lastArg ? ->
  else
    reportMissingSource name if args.length < 2
    [..., lastArg] = args
    if typeof lastArg is 'string'
      [args..., dest] = args
    [src] = args
    if typeof src is 'function'
      pipes = args[1..]
    else
      [src, srcs, pipes] = gulpSrcForArgs args
  {name, deps, callback, src, srcs, pipes, dest}
