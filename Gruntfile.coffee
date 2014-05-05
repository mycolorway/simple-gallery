module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'


    sass:
      gallery:
        options:
          style: 'expanded'
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
          'spec/gallery-spec.js': 'spec/gallery-spec.coffee'

    watch:
      styles:
        files: ['styles/*.scss']
        tasks: ['sass']
      scripts:
        files: ['src/*.coffee', 'spec/*.coffee']
        tasks: ['coffee']
      jasmine:
        files: [
          'styles/gallery.css',
          'lib/module.js',
          'lib/util.js',
          'lib/gallery.js',
          'specs/*.js'
        ],
        tasks: 'jasmine:test:build'

    jasmine:
      test:
        src: [
          'lib/module.js',
          'lib/util.js',
          'lib/gallery.js'
        ]
        options:
          outfile: 'spec/index.html'
          styles: 'styles/gallery.css'
          specs: 'spec/gallery-spec.js'
          vendor: ['vendor/bower/jquery/dist/jquery.min.js']

  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-connect'

  grunt.registerTask 'default', ['coffee', 'jasmine:test:build', 'watch']
