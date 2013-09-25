
module.exports =
  reloader:
    start: ->
      delay = -> setTimeout arguments[1], arguments[0]
      module.exports = ->
        INITIAL_DELAY = 2000
        INTERVAL      = 1000
        t0            = ( new Date ).getTime()
        time          = null
        do iter = -> delay INTERVAL, ->
          $.get '/modified', (d) ->    
            initial_delay_ok = ( ( new Date() ).getTime() - t0 ) > INITIAL_DELAY
            different        = (typeof time is 'string') and ( time isnt d )      
            if initial_delay_ok and different
              document.location.reload()
            else
              time = d
              iter()