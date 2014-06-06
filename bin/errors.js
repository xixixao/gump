// Generated by CoffeeScript 1.7.1
(function() {
  var GumpError, gutil,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  gutil = require('gulp-util');

  exports.GumpError = GumpError = (function(_super) {
    __extends(GumpError, _super);

    function GumpError(message, log) {
      this.log = log;
      GumpError.__super__.constructor.call(this, message);
    }

    return GumpError;

  })(Error);

  exports.reportMissingSource = function(name) {
    var cyan, red, _ref;
    _ref = gutil.colors, red = _ref.red, cyan = _ref.cyan;
    throw new GumpError('Gump Error: missing source', function() {
      return gutil.log(red('[Gump Fatal Error]', red('Succinct style used for'), cyan(name), red('but missing a source glob!')));
    });
  };

  exports.reportMissingStyle = function(name) {
    var cyan, red, _ref;
    _ref = gutil.colors, red = _ref.red, cyan = _ref.cyan;
    throw new GumpError('Gump Error: missing arguments', function() {
      return gutil.log(red('[Gump Fatal Error]', red('Missing additional arguments for'), cyan(name)));
    });
  };

  exports.reportWrongUseOfWatch = function(name) {
    var cyan, red, _ref;
    _ref = gutil.colors, red = _ref.red, cyan = _ref.cyan;
    throw new GumpError('Gump Error: wrong arguments', function() {
      return gutil.log(red('[Gump Fatal Error]', red('Watching'), cyan(name), red('requires succinct style, but callback given')));
    });
  };

  exports.catchGumpErrors = function(fn) {
    var error;
    try {
      fn();
    } catch (_error) {
      error = _error;
      if (error instanceof GumpError) {
        error.log();
      } else {
        throw error;
      }
    }
  };

}).call(this);
