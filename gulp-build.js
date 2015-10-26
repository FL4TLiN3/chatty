
var babelify = require('babelify')
  , browserify = require('browserify')
  , gulp = require('gulp')
  , uglify = require('gulp-uglify')
  , watchify = require('watchify')
  , buffer = require('vinyl-buffer')
  , source = require("vinyl-source-stream");

var gulpBuild = module.exports = function (debug) {
  var bundler;
  var options = {
    entries: 'web/static/js/app.jsx',
    extensions: ['.js', '.jsx'],
    transform: [babelify]
  };

  if (debug) {
    options.cache = {};
    options.packageCache = {};
    options.debug = debug;
    bundler = watchify(browserify(options));
    bundler.on('update', build);
    bundler.on('log', function (msg) { console.log(msg); });
  } else {
    bundler = browserify(options);
  }

  function build () {
    var outputFilename;
    if (debug) {
      outputFilename = 'app.js';
    } else {
      outputFilename = 'app.min.js';
    }

    var stream = bundler.bundle()
    .on('error', function (error) { console.error(error.stack); })
    .pipe(source(outputFilename))
    .pipe(buffer());

    if (!debug) {
      stream = stream.pipe(uglify());
    }

    return stream.pipe(gulp.dest('priv/static/js'));
  };

  return build;
};
