flour = require 'flour'

flour.minifiers.js = null

task 'build:coffee', ->
    compile 'src/*.coffee', 'lib/*'

task 'watch', ->
    invoke 'build:coffee'
    watch 'src/', -> invoke 'build:coffee'
