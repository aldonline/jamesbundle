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




module.exports =
  ###
  Scan a js bundle for the initial require() entry point
  ###
  get_initial_require: ( js_bundle ) ->
    if ( x = get_jamesbundle_require_entry js_bundle )?
      x = x.split('/')
      x[x.length - 1] = 'jamesbundle' # name of the file sans extension
      x.join '/'
    else
      null