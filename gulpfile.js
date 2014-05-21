var gulp = require('gulp');
var stylish = require('jshint-stylish');
var plugins = require("gulp-load-plugins")();
var pkg = require('./package.json');
var gutil = require('gulp-util');


gulp.task('scripts', function() {
    // Single entry point to browserify
    gulp.src([
    	'MG/Classes/Commands/js/src/require.js',
    	'MG/Classes/Commands/js/src/macgap.js',
    	'MG/Classes/Commands/js/src/!(init)*.js',
    	'!MG/Classes/Commands/js/src/bridge.js',
       	'MG/Classes/Commands/js/src/init.js',
    	])
		.pipe(plugins.jshint('.jshintrc'))
    	.pipe(plugins.jshint.reporter(stylish))
    	.pipe(plugins.concat('macgap.js'))
    	.pipe(gulp.dest('./MG/Classes/Commands/js/'))      

});


gulp.task('default', ['scripts']);
