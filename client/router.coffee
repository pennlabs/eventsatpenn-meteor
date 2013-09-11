Meteor.Router.add
  '/': ->
    Session.set('after_date')  # clear
    return 'all'
  '/new': 'new'
  '/login': 'login'
  '/event/:event_id': (event_id) ->
    Session.set("event_id", event_id)
    return 'event_info'
  '/user/:user_id': (user_id) ->
    Session.set("user_id", user_id)
    return 'user'
  '/search/:q': (q) ->
    Session.set("q", decodeURIComponent q)
    return 'search'
  '/category/:categories': (categories) ->
    categories = decodeURIComponent(categories)
    Session.set("categories", categories.split('+'))
    return 'category'
  '/after/:date': (date) ->
    Session.set('after_date', decodeURIComponent date)
    return 'after_date'
