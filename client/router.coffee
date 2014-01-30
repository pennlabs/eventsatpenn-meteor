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
  '/event/:title_id': (title_id) ->
    event_id = Events.findOne(title_id: encodeURIComponent(title_id))
    Session.set("event_id", event_id)
    return 'event_info'
  '/user/:user_id': (user_id) ->
    Session.set("user_id", user_id)
    return 'show_user'
  '/settings': () -> 'edit_user'
  '/search': (q) ->
    Session.set('params', parse_pararms @querystring)
    return 'search'

Meteor.Router.filters 'requireLogin': (page) ->
  if Meteor.user() then page else 'login'

Meteor.Router.filter 'requireLogin',
  only:
    [
      'new_event',
      'edit_user'
    ]
