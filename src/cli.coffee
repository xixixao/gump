fs = require 'fs'
spawn = require('child_process').spawn
chalk = require 'chalk'
semver = require 'semver'
Liftoff = require 'liftoff'
tildify = require 'tildify'
interpret = require 'interpret'
argv = require('minimist') process.argv.slice 2
evil = require 'eval'

log = (args...) ->
  console.log chalk.gray('(Gump)'), args...

globalCli = require '../package'
versionFlag = argv.v or argv.version

new Liftoff
  name: 'gump'
  extensions: interpret.jsVariants
.launch
  cwd: argv.cwd
  configPath: argv.gumpfile
, (env) ->
  if versionFlag
    log "CLI version", globalCli.version
    if env.modulePackage
      log "Local version", env.modulePackage.version
    process.exit 0
  unless env.modulePath
    log chalk.red("Local Gump not found in"), chalk.magenta(tildify(env.cwd))
    log chalk.red("Try running: npm install Gump")
    process.exit 1
  unless env.configPath
    log chalk.red("No gumpfile found")
    process.exit 1

  # check for semver difference between cli and local installation
  if semver.gt globalCli.version, env.modulePackage.version
    log chalk.red("Warning: Gump version mismatch:")
    log chalk.red("Global Gump is", globalCli.version)
    log chalk.red("Local Gump is", env.modulePackage.version)

  # chdir before requiring gulpfile to make sure
  # we let them chdir as needed
  if process.cwd() isnt env.cwd
    process.chdir env.cwd
    log "Working directory changed to", chalk.magenta(tildify(env.cwd))

  gumpfile = appendGumpCall fs.readFileSync env.configPath, 'utf-8'

  # this is what actually loads up the gulpfile
  # TODO: load gumpfile, find top level functions, add them as tasks
  # gulp = spawn 'gulp', process.argv[2..].concat('--gulpfile', env.configPath),
  #   cwd: process.cwd
  #   stdio: 'inherit'

  evil gumpfile
  if shouldLog
    gutil.log "Using gulpfile", chalk.magenta(tildify(env.configPath))
  gumpInst = require env.modulePath
  process.nextTick ->
    gumpInst.run toRun...


