// Generated by CoffeeScript 1.7.1
(function() {
  var Pipe, Task, async, asyncDone, browserSync, cache, catchGumpErrors, clean, combine, filter, globsToStream, gulp, handleDeletion, livereload, map, mark, memory, notify, once, parseArguments, path, pipe, plumber, promisify, reloadIfServed, rememberMarked, reportWrongUseOfWatch, run, runSingle, runTask, serving, shouldServe, subdir, tasks, unique, _ref,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  path = require('path');

  gulp = require('gulp');

  cache = require('gulp-cached');

  notify = require('gulp-notify');

  filter = require('gulp-filter');

  plumber = require('gulp-plumber');

  clean = require('gulp-clean');

  combine = require('ordered-read-streams');

  once = require('once');

  subdir = require('subdir');

  browserSync = require('browser-sync');

  asyncDone = require('async-done');

  async = require('async');

  promisify = require('bluebird').promisify;

  map = require('vinyl-map');

  unique = require('unique-stream');

  _ref = require('./errors'), reportWrongUseOfWatch = _ref.reportWrongUseOfWatch, catchGumpErrors = _ref.catchGumpErrors;

  parseArguments = require('./argumentparsing').parseArguments;

  globsToStream = require('./globbing').globsToStream;

  map = function(fn) {
    return filter(function(file) {
      fn(file);
      return true;
    });
  };

  pipe = function(stream, pipes, dest) {
    var step, _i, _len;
    for (_i = 0, _len = pipes.length; _i < _len; _i++) {
      step = pipes[_i];
      stream = stream.pipe(step());
    }
    if (dest) {
      stream = stream.pipe(gulp.dest(dest));
    }
    return stream;
  };

  exports.task = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return catchGumpErrors(function() {
      var callback, deps, dest, name, pipes, src, _ref1;
      _ref1 = parseArguments(args), name = _ref1.name, deps = _ref1.deps, callback = _ref1.callback, src = _ref1.src, pipes = _ref1.pipes, dest = _ref1.dest;
      return gulp.task(name, deps, callback || function() {
        return pipe(src(), pipes, dest);
      });
    });
  };

  serving = void 0;

  shouldServe = function(file) {
    if (serving != null) {
      return subdir(serving.dir, file.path);
    }
  };

  livereload = function(file) {
    serving.instance.changeFile(file.path, {
      injectFileTypes: ['css', 'png', 'jpg', 'jpeg', 'svg', 'gif', 'webp']
    });
    return true;
  };

  reloadIfServed = function(stream, message) {
    return stream.pipe(filter(shouldServe)).pipe(notify("" + message + " <%= file.relative %>")).pipe(filter(livereload));
  };

  mark = function(file) {
    return file.__original = file.path;
  };

  memory = {};

  rememberMarked = function(file) {
    return memory[file.__original] = file.path;
  };

  handleDeletion = function(_arg) {
    var path, stream, type;
    type = _arg.type, path = _arg.path;
    if (type === 'deleted') {
      stream = gulp.src(memory[path]).pipe(clean());
      return reloadIfServed(stream, 'Deleted');
    }
  };

  exports.watch = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return catchGumpErrors(function() {
      var callback, deps, dest, name, pipes, src, srcs, _ref1;
      _ref1 = parseArguments(args), name = _ref1.name, deps = _ref1.deps, callback = _ref1.callback, src = _ref1.src, srcs = _ref1.srcs, pipes = _ref1.pipes, dest = _ref1.dest;
      if (callback) {
        reportWrongUseOfWatch(name);
      }
      return gulp.task(name, deps, function() {
        var stream;
        once(function() {
          return gulp.watch(srcs, [name]).on('change', handleDeletion);
        })();
        stream = src().pipe(cache(name)).pipe(plumber()).pipe(map(mark));
        stream = pipe(stream, pipes, dest).pipe(map(rememberMarked));
        return reloadIfServed(stream, 'Compiled');
      });
    });
  };

  exports.serve = function(baseDir) {
    if (baseDir == null) {
      baseDir = './';
    }
    return catchGumpErrors(function() {
      return serving = {
        dir: baseDir,
        instance: browserSync.init([], {
          server: {
            baseDir: baseDir
          },
          notify: false
        })
      };
    });
  };

  exports.setGulp = function(gulpInstance) {
    return gulp = gulpInstance;
  };

  tasks = {};

  exports.tasks = function(tasksDefinition) {
    var name, taskFn, _fn;
    tasks = tasksDefinition;
    _fn = function(name, taskFn) {
      var task;
      tasksDefinition[name] = task = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return new Task(name, taskFn.bind.apply(taskFn, [tasksDefinition].concat(__slice.call(args))));
      };
      task.isTask = true;
      return gulp.task(name, function() {
        return run(task());
      });
    };
    for (name in tasksDefinition) {
      if (!__hasProp.call(tasksDefinition, name)) continue;
      taskFn = tasksDefinition[name];
      _fn(name, taskFn);
    }
  };

  exports.pipe = function() {
    var arg, args, globs, mutators, sources, _i, _len;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    globs = [];
    sources = [];
    mutators = [];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      arg = args[_i];
      if (__indexOf.call(tasks, arg) >= 0) {
        sources.push(arg());
      } else if (arg instanceof Task) {
        sources.push(arg);
      } else if (typeof arg === 'string') {
        globs.push(arg);
      } else {
        mutators.push(arg);
      }
    }
    sources.push(globsToStream(globs));
    return new Pipe(sources, mutators);
  };

  Task = (function() {
    function Task(name, body) {
      this.name = name;
      this.body = body;
    }

    return Task;

  })();

  Pipe = (function() {
    function Pipe(sources, mutators) {
      this.sources = sources;
      this.mutators = mutators;
    }

    Pipe.prototype.run = function(cb) {
      var step, stream, _i, _len, _ref1;
      stream = combine(this.sources);
      stream = stream.pipe(unique('path'));
      _ref1 = this.mutators;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        step = _ref1[_i];
        stream = stream.pipe(step());
      }
      return asyncDone((function() {
        return stream;
      }), cb);
    };

    return Pipe;

  })();

  runTask = function(task) {
    return function(cb) {
      return asyncDone.sync(task.body, function(err, result) {
        if (result instanceof Pipe) {
          return result.run(cb);
        } else {
          return cb(err, result);
        }
      });
    };
  };

  runSingle = function(arg) {
    if (arg.isTask) {
      runTask(arg());
    }
    if (arg instanceof Task) {
      return runTask(arg);
    } else if (arg instanceof Pipe) {
      return function(cb) {
        return arg.run(cb);
      };
    } else {
      return function(cb) {
        return asyncDone.sync(arg, cb);
      };
    }
  };

  exports.run = run = function() {
    var arg, args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    tasks = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        arg = args[_i];
        if (Array.isArray(arg)) {
          _results.push(function(cb) {
            return async.parallel(arg.map(runSingle), cb);
          });
        } else {
          _results.push(runSingle(arg));
        }
      }
      return _results;
    })();
    return promisify(async.series)(tasks);
  };

  exports.to = gulp.dest;

}).call(this);
