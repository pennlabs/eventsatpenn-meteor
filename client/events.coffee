Meteor.subscribe("userData")

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

Template.user.events
  'click .follow': (e) ->
    e.preventDefault()
    # Meteor.users.update(Meteor.userId(), {$set:
    console.log "following"

Template.all.all_events = -> Events.find().fetch()

# events template
Template.events.user_event_queue = ->
  Events.find().fetch()

Template.events.general_event_queue = ->
  Events.find().fetch()

# user template
Template.user.info = ->
  Meteor.users.findOne(Session.get("user_id"))

Template.user.user_events = ->
  Events.find(created_by: Session.get("user_id")).fetch()

Template.event.info = ->
  event = Events.findOne(Session.get("event_id"))
  return event

Meteor.Router.add
  '/': 'events'
  '/all': 'all'
  '/new': 'new'
  '/event/:event_id': (event_id) ->
    Session.set("event_id", event_id)
    return 'event'
  '/user/:user_id': (user_id) ->
    Session.set("user_id", user_id)
    return 'user'
