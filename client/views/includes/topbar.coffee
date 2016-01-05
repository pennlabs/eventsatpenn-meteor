Template.topbar.helpers
  'q': -> Session.get("params")?.q

Template.topbar.events
  'click .menu-icon': (e) ->
    e.preventDefault()
    $('.top-bar-section').toggle()
  'submit .search': (e) ->
    e.preventDefault()
    params = Session.get("params") or {}
    params.q = $('#searchbox').val()
    Router.go "/search?#{window.events_at_penn.serialize params}"

Template.topbar.rendered = ->
  if !window.foundation?
    $(document).foundation -> window.foundation = true

  if !window._gaq?
    window._gaq = []
    _gaq.push(['_setAccount', 'UA-12991053-1'])
    _gaq.push(['_trackPageview'])
    (->
      ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true
      gajs = '.google-analytics.com/ga.js'
      ga.src = if 'https:' is document.location.protocol then 'https://ssl'+gajs else 'http://www'+gajs
      s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s)
    )()
