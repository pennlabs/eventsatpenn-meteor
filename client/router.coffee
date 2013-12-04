parse_pararms = (querystring) ->
  params = {}
  querystring = querystring.split('&')
  for qs in querystring
    continue if not qs
    pair = qs.split('=')
    params[decodeURIComponent pair[0]] = decodeURIComponent pair[1]
  params

Meteor.Router.add
  '/': ->
    Session.set('params', parse_pararms @querystring)
    return 'all'
  '/new': 'new_event'
  '/login': 'login'
  '/event/:event_id': (event_id) ->
    Session.set("event_id", event_id)
    return 'event_info'
  '/user/:user_id': (user_id) ->
    Session.set("user_id", user_id)
    return 'user'
  '/search': (q) ->
    Session.set('params', parse_pararms @querystring)
    return 'search'
