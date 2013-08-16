Meteor.Router.add
  '/': 'events'
  '/all': 'all'
  '/new': 'new'
  '/login': 'login'
  '/event/:event_id': (event_id) ->
    Session.set("event_id", event_id)
    return 'event_info'
  '/user/:user_id': (user_id) ->
    Session.set("user_id", user_id)
    return 'user'
  '/search/:q': (q) ->
    Session.set("q", decodeURIComponent(q))
    return 'search'
