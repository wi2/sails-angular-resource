'use strict';

var gulp = require('gulp'),
    uglify = require('gulp-uglify'),
    coffee = require('gulp-coffee'),
    gutil = require('gulp-util');


gulp.task('coffee', function() {
  gulp.src('./src/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./build/'))
});


gulp.task('build-js', function () {
  gulp.src('./build/*.js')
    .pipe(gulp.dest('./dist/'))
    .pipe(uglify())
    .pipe(gulp.dest('./dist/'));
});

gulp.task('default', ['coffee', 'build-js']);