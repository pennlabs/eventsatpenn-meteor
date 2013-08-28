Meteor.Router.add
  '/': 'all'
  '/feed': 'events'
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
  '/category/:category': (category) ->
    Session.set("category", decodeURIComponent(category))
    return 'category'
