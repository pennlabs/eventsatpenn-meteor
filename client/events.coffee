Template.events.events
  'submit .search-form': (e) ->
    e.preventDefault()
    q = $('#search-term').val()
    console.log q

Template.new.events
  'submit .create-event': (e) ->
    e.preventDefault()
    # event = $('.create-event').serializeObject()
    console.log "form submitted"

Meteor.Router.add
  '/': 'events'
  '/new': 'new'
  '/event/:id': (event_id) ->
    console.log event_id
    return 'event'
  '/user/:id': (user_id) ->
    console.log user_id
    return 'user'
