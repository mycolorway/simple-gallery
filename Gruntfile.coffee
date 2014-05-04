module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    sass:
      styles:
        options:
          style: 'expanded'
        files:
          'styles/gallery.css': 'styles/gallery.scss'
    connect:
      uses_defaults: {}
    coffee:
      module:
        files:
          'lib/module.js': 'externals/simple-module/src/module.coffee'
      util:
        files:
          'lib/util.js': 'externals/simple-util/src/util.coffee'
      gallery:
        files:
          'lib/gallery.js': 'src/gallery.coffee'
      spec:
        files:
          'spec/lib/gallery-spec.js': 'spec/src/gallery-spec.coffee'
    watch:
      styles:
        files: ['styles/*.scss']
        tasks: ['sass']
      scripts:
        files: ['src/**/*.coffee', 'spec/src/**/*.coffee']
        tasks: ['coffee']
    jasmine:
      pivotal:
        src: 'lib/gallery.js'
        options:
          vendor: ['lib/module.js', 'externals/jquery-2.0.3.js']
          specs: 'spec/lib/gallery-spec.js'
          summary: true
          host : 'http://127.0.0.1:8000/'

  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-connect'

  grunt.registerTask 'test', ['sass', 'coffee', 'connect', 'jasmine']
