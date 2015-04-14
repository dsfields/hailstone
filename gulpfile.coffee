Del = require 'del'
Gulp = require 'gulp'
GulpCoffee = require 'gulp-coffee'
GulpCoffeelint = require 'gulp-coffeelint'
GulpEslint = require 'gulp-eslint'
GulpMocha = require 'gulp-mocha'
GulpSourceMaps = require 'gulp-sourcemaps'
GulpUtil = require 'gulp-util'
RunSequence = require 'run-sequence'

Gulp.task 'coffeelint', () ->
  Gulp.src ['./**/*.coffee', '!./node_modules/**']
  .pipe GulpCoffeelint()
  .pipe GulpCoffeelint.reporter()

Gulp.task 'eslint', () ->
  Gulp.src(['./**/*.js', '!./node_modules/**'])
  .pipe GulpEslint()
  .pipe GulpEslint.format()

Gulp.task 'lint', ['coffeelint', 'eslint']

Gulp.task 'test', () ->
  require 'coffee-script/register'
  Gulp.src 'tests/unit/**/*.coffee'
  .pipe GulpMocha(reporter: 'spec')

Gulp.task 'clean', (cb) ->
  Del ['./lib'], {force: true}, cb

Gulp.task 'compile', ->
  Gulp.src ['./src/**/*.coffee']
  .pipe GulpSourceMaps.init()
  .pipe(GulpCoffee(bare: true)).on 'error', GulpUtil.log
  .pipe GulpSourceMaps.write('./maps')
  .pipe Gulp.dest('./lib')

Gulp.task 'copyJs', () ->
  Gulp.src ['./src/**/*.js'], { base: './src' }
  .pipe Gulp.dest('./lib')

Gulp.task 'build', () ->
  RunSequence 'clean', 'compile', 'copyJs'

Gulp.task 'default', ['lint', 'test']