

str = '''


require.define("mesbundle.coffee",function(require,module,exports,__dirname,__filename,process,global){(function() {
  var build_toc, raml;



require.define("/fooo/jasbundle.coffee",function(require,module,exports,__dirname,__filename,process,global){(function() {
  var build_toc, raml;



require.define("/jamundle.coffee",function(require,module,exports,__dirname,__filename,process,global){(function() {
  var build_toc, raml;


require.define("foo/bar/jamesbundle.coffee",function(require,module,exports,__dirname,__filename,process,global){(function() {
  var build_toc, raml;


'''

get_require_entries = ( js_bundle ) ->
    re = ///
      require.define
      \("([^\"]+)"
      ///g
    f[1] while ( f = re.exec js_bundle )?

get_jamesbundle_require_entry = ( js_bundle ) ->
  for e in get_require_entries js_bundle
    es = e.split '/'
    if es.pop() in ['jamesbundle.coffee', 'jamesbundle.js', 'jamesbundle']
      return e
  return null

get_initial_require = ( js_bundle ) ->
  if ( x = get_jamesbundle_require_entry js_bundle )?
    x = x.split('/')
    x[x.length - 1] = 'jamesbundle'
    x.join '/'
  else
    null


console.log get_initial_require str