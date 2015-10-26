
var gulp = require('gulp')
  , gulpBuild = require('./gulp-build')
  , autoprefixer = require('gulp-autoprefixer')
  , concat = require('gulp-concat')
  , dirSync = require('gulp-dir-sync')
  , minifyCss = require('gulp-minify-css')
  , order = require("gulp-order")
  , rename = require("gulp-rename")
  , sass = require('gulp-sass')
  , sourcemaps = require('gulp-sourcemaps')
  , watch = require('gulp-watch');

gulp.task('build-js:development', gulpBuild(true));
gulp.task('build-js:production', gulpBuild());

gulp.task('build-vendor-js', function() {
  return gulp.src(['web/static/vendor/jquery.js', 'web/static/vendor/bootstrap.js'])
    .pipe(order([
      "jquery.js",
      "bootstrap.js"
    ]))
    .pipe(concat('vendor.js'))
    .pipe(gulp.dest('priv/static/js'));
});

gulp.task('build-style', function () {
  return gulp.src('web/static/css/app.scss')
    .pipe(sourcemaps.init())
    .pipe(sass().on('error', sass.logError))
    .pipe(autoprefixer())
    .pipe(sourcemaps.write('./'))
    .pipe(rename('app.css'))
    .pipe(gulp.dest('priv/static/css'));
});

gulp.task('build-style-admin', function () {
  return gulp.src('web/static/css_admin/app.scss')
    .pipe(sourcemaps.init())
    .pipe(sass().on('error', sass.logError))
    .pipe(autoprefixer())
    .pipe(sourcemaps.write('./'))
    .pipe(rename('admin.css'))
    .pipe(gulp.dest('priv/static/css'));
});

gulp.task('watch-style', function () {
  watch([
    'web/static/css/**/*.*'
  ], function () {
    gulp.start('build-style');
  });
});

gulp.task('watch-style-admin', function () {
  watch([
    'web/static/css_admin/**/*.*'
  ], function () {
    gulp.start('build-style-admin');
  });
});

gulp.task('sync-assets', function() {
  dirSync('web/static/assets', 'priv/static');
});

gulp.task('default', [
  'build-js:development',
  'build-vendor-js',
  'build-style',
  'watch-style',
  'build-style-admin',
  'watch-style-admin',
  'sync-assets'
]);
