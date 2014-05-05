module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'


    sass:
      gallery:
        options:
          style: 'expanded'
          bundleExec: true
        files:
          'styles/gallery.css': 'styles/gallery.scss'

    coffee:
      module:
        files:
          'lib/module.js': 'vendor/bower/simple-module/src/module.coffee'
      util:
        files:
          'lib/util.js': 'vendor/bower/simple-util/src/util.coffee'
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
        files: ['lib/**/*.js', 'specs/**/*.js'],
        tasks: 'jasmine:test:build'

    jasmine:
      test:
        src: 'lib/**/*.js'
        options:
          outfile: 'spec/index.html'
          specs: 'spec/util-spec.js'
          vendor: ['vendor/bower/jquery/dist/jquery.min.js']

  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-connect'

  grunt.registerTask 'default', ['coffee', 'jasmine:test:build', 'watch']
