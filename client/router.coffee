Meteor.Router.add
  '/': ->
    Session.set('params')  # clear
    return 'all'
  '/new': 'new'
  '/login': 'login'
  '/event/:event_id': (event_id) ->
    Session.set("event_id", event_id)
    return 'event_info'
  '/user/:user_id': (user_id) ->
    Session.set("user_id", user_id)
    return 'user'
  '/search': (q) ->
    params = {}
    querystring = @querystring.split('&')
    for qs in querystring
      pair = qs.split('=')
      params[decodeURIComponent pair[0]] = decodeURIComponent pair[1]
    Session.set('params', params)
    return 'search'
