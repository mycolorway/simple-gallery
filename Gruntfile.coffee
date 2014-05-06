module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'


    sass:
      gallery:
        options:
          style: 'expanded'
        files:
          'lib/gallery.css': 'src/gallery.scss'

    coffee:
      gallery:
        files:
          'lib/gallery.js': 'src/gallery.coffee'
      spec:
        files:
          'spec/gallery-spec.js': 'spec/gallery-spec.coffee'

    watch:
      styles:
        files: ['src/*.scss']
        tasks: ['sass']
      scripts:
        files: ['src/*.coffee', 'spec/*.coffee']
        tasks: ['coffee']
      jasmine:
        files: [
          'lib/gallery.css',
          'lib/gallery.js',
          'specs/*.js'
        ],
        tasks: 'jasmine:test:build'

    jasmine:
      test:
        src: ['lib/gallery.js']
        options:
          outfile: 'spec/index.html'
          styles: 'lib/gallery.css'
          specs: 'spec/gallery-spec.js'
          vendor: [
            'vendor/bower/jquery/dist/jquery.min.js',
            'vendor/bower/simple-module/lib/module.js',
            'vendor/bower/simple-util/lib/util.js'
          ]

  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-connect'

  grunt.registerTask 'default', ['coffee', 'jasmine:test:build', 'watch']
