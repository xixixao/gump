path = require 'path'
globStream = require 'glob-stream'
combine = require 'ordered-read-streams'

BASE_PATH_SEPARATOR = '|'

countSubstrings = (string, substring) ->
  count = 0
  pos = string.indexOf substring
  while pos >= 0
    count++
    pos = string.indexOf substring, pos + 1
  count

findBase = (glob) ->
  numSubstrings = countSubstrings glob, BASE_PATH_SEPARATOR
  if numSubstrings > 1
    error "too many base separators"
  else if numSubstrings == 1
    [base, rest] = glob.split BASE_PATH_SEPARATOR
    {base, glob: path.join base, rest}
  else
    {glob}

findNegative = (glob) ->
  if glob[0] is '!'
    negative: glob
  else if countSubstrings(glob, '{!') > 0
    positive = glob.replace /\{(\!+)[^\}]+\}/, (pattern, negators) ->
      if negators.length == 2
        '**'
      else
        '*'
    negative = '!' + glob.replace /\{\!+([^\}]+)\}/, '{$1}'
    {positive, negative}
  else
    positive: glob

exports.globsToStream = (globs) ->
  globsWithBase = globs.map findBase
  globsPosNeg = globsWithBase.map ({glob, base}) ->
    {positive, negative} = findNegative glob
    {positive, negative, base}
  negatives = globsPosNeg.filter ({negative}) -> negative?
    .map ({negative}) -> negative
  globsPositive = globsPosNeg.filter ({positive}) -> positive?
  streams = for {positive, base} in globsPositive
    globStream.create [positive].concat(negatives), {base}
  combine streams
