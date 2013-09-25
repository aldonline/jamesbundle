browserify      = require 'browserify'
uglify          = require 'uglify-js'
path_module     = require 'path'
_               = require 'underscore'
file_module     = require 'file'
fs              = require 'fs'

util            = require './util'
styles          = require './styles'
scripts         = require './scripts'

module.exports = create = ( {production, data} = {} ) -> 
  sc = scripts {production, data}
  st = styles {production}

  mount: ( app ) ->
    st.mount app
    sc.mount app

  html: ->
    st.html() + sc.html()