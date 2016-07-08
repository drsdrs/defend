module.exports = (grunt) ->

  grunt.initConfig

    livereload :
      options:
        base: 'coffee'
      files: ['coffee/**/*.coffee','cordova/www/']

    watch:
      client:
        files: ['coffee/**/*.coffee']
        tasks: ['coffeelint', 'coffee']
        reload: true

    coffee:
      compile:
        options:
          sourceMap: true
        files:
          'public/js/main.js':'coffee/**/*.coffee'

    coffeelint:
      options:
        'max_line_length':
          'level': 'ignore'
      files: 'coffee/**/*.coffee'

    grunt.registerTask 'serve', (env) ->
      express = require('express')
      app = express()
      app.use(express.static(__dirname + '/public'))
      app.use(express.static(__dirname + '/bower_components'))
      app.get '/', (req, res) -> res.sendfile __dirname + './public/index.html'
      console.log 'serving website on localhost:8000'
      app.listen(8000)

    grunt.registerTask 'cordova', (env) ->
      fs = require('fs-extra')
      exec = require('child_process').exec
      done = @async()
      grunt.task.run ['coffeelint', 'coffee']
      fs.copy 'public/js/main.js', 'defend_cordova/www/js/main.js', (err)->
        throw err if err
        fs.copy 'public/assets/', 'defend_cordova/www/assets/', (err)->
          throw err if err
          exec(
            'cordova run android'
            cwd: 'defend_cordova'
            (err, stdout, stderr)->
              throw err if err
              done()
          )


    grunt.registerTask 'default', (env) ->
      grunt.task.run ['serve', 'coffeelint', 'coffee', 'watch']

  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-livereload')

