browserify      = require 'browserify'
uglify          = require 'uglify-js'
path_module     = require 'path'
_               = require 'underscore'
file_module     = require 'file'
fs              = require 'fs'
util            = require './util'
# styles          = require './styles'

find_main_script = (root) ->
  file = null
  file_module.walkSync root, (path, dirs, files) ->
    if path.indexOf('node_modules') is -1
      for f in files
        if f.split('.')[0] is 'jamesbundle'
          file = path_module.resolve path, f
          break
  file.split('.')[0...-1].join('.')


# https://github.com/substack/node-browserify/issues/75
uglify_filter = (str) -> uglify.minify( str, {fromString: true }).code


module.exports = create = ( {production, data} = {} ) -> 
  production ?= no
  root_dir = process.cwd()
  
  main_script = find_main_script root_dir

  b = browserify 
    require:  main_script
    watch: not production

  client_data =
    production: production or no
    data: data or {}
  initial_req = util.get_initial_require b.bundle()
  entry = "require('#{initial_req}')(" + (JSON.stringify client_data) + ")"

  get_bundle = ->
    # TODO: prevent syntax error from breaking reloading
    # and show it as debug feedback
    err = null
    b.on 'syntaxError', (e) -> err = e
    b.bundle()

  b_min = browserify 
    require:  main_script
    watch:    not production
    filter:   uglify_filter

  wrap_bundle = ( bundle_str ) -> bundle_str + ' ; ' + entry

  get_cached_bundle = _.memoize -> wrap_bundle b_min.bundle()
  mount_js = (app, path, js_str) ->
    app.get path, ( _, res ) ->
      res.setHeader 'Content-Type', 'application/javascript'
      res.end js_str()

  
  html: ->
    if production
      '<script src="/jamesbundle.min.cached.js"></script>'
    else
      '<script src="/jamesbundle.js"></script>'


  mount: (app) ->
    mount_js app, '/jamesbundle.js', -> wrap_bundle b.bundle()
    mount_js app, '/jamesbundle.min.js' , -> wrap_bundle b_min.bundle()
    mount_js app, '/jamesbundle.min.cached.js' , -> get_cached_bundle()

    app.get '/jamesbundle-modified', (req, res, next) ->
      res.setHeader 'Content-Type', 'text/plain'
      b.bundle()
      res.end b.modified.toString()