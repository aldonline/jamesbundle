file   = require 'file'
path   = require 'path'
recess = require 'recess'
_      = require 'underscore'
express = require 'express'

###

# https://npmjs.org/package/less-tree-watch
# https://github.com/less/less.js/wiki/Browser-Options

###

root = process.cwd()

class Stylesheet
  constructor: ( @abspath, @alias ) ->
  mount_path: ->  "/jamesbundle--#{@alias}"
  mount: ( express_app ) ->
    express_app.get @mount_path(), (req, res) =>
      res.sendfile @abspath

list_stylesheets = ->
  result = []
  console.log 'will list stylesheets'
  file.walkSync root,  ( path, dirs, files ) ->
    if path.indexOf('node_modules') is -1
      for f in files when f.split('.').pop() is 'less'
        abspath = path + '/' + f
        alias = abspath[root.length..].replace '/', '--'
        s = new Stylesheet abspath, alias
        result.push s
  console.log 'stylesheets = ', JSON.stringify result
  result

bundle = (cb) ->
  paths = _.pluck list_stylesheets(), 'abspath'
  console.log 'will compress stylesheets', JSON.stringify paths
  recess paths, {compile:yes, compress:yes}, ( e, r ) ->
    return cb e if e?
    console.log 'style compilation successful'
    cb null, ( _.pluck r, 'data' ).join '\n'

_cache = null
bundle_cached = (cb) ->
  if cache?
    cb null, cache
  else
    bundle (e,r) ->
      if e? then return cb e
      cb null, _cache = r

css = (url) -> '<link rel="stylesheet" href="' + url + '"/>'
csss = (urls) -> ( css url for url in urls ).join '\n'

module.exports = ( {production} ) ->

  mount: ( express_app ) ->
    s.mount express_app for s in list_stylesheets()
    express_app.get '/jamesbundle.css', (req, res) ->
      bundle (e, r) ->
        res.setHeader 'Content-Type', 'text/css'
        res.send r
  
    express_app.get '/jamesbundle.cached.css', (req, res) ->
      bundle_cached (e, r) ->
        res.setHeader 'Content-Type', 'text/css'
        res.send r

    assets_dir = path.resolve __dirname, '../assets'
    express_app.use "/jamesbundle/assets", express.static assets_dir

  # get_mounted_paths: -> s.mount_path() for s in list_stylesheets()
  html: ->

    if production
      csss [
          '/jamesbundle.cached.css'
        ]
    else
      do ->
        styles = do ->
          ss = for s in list_stylesheets()
            '<link rel="stylesheet/less" type="text/css" href="' + s.mount_path() + '" />'
          ss.join '\n'
        """
          <script type="text/javascript">
              less = {
                async: false,
                fileAsync: false,
                env: "development",
                poll: 1000
              };
          </script>
          #{styles}
          <script src="/jamesbundle/assets/less-1.4.1.min.js"></script>
          <script>less.watch()</script>
        """
