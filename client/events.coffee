Meteor.subscribe("userData")

$.fn.serializeObject = ->
  o = {}
  a = @serializeArray()
  $.each a, ->
    if o[@name] isnt undefined
      o[@name] = [o[@name]]  unless o[@name].push
      o[@name].push @value or ""
    else
      o[@name] = @value or ""
  return o

Template.events.events
  'submit .search-form': (e) ->
    e.preventDefault()
    q = $('#search-term').val()
    console.log q

Template.new.events
  'submit .create-event': (e) ->
    e.preventDefault()
    event = $('.create-event').serializeObject()
    event.created_by = Meteor.userId()
    console.log event

    event_id = Events.insert(event)
    Meteor.call('create_event', event_id)

Template.user.events
  'click .follow': (e) ->
    e.preventDefault()
    Meteor.call("follow_user", Session.get("user_id"))

Template.all.all_events = -> Events.find().fetch()

# events template
Template.events.event_queue = ->
  if Meteor.user()
    event_ids = Meteor.user().event_queue or []
    return Events.find(_id: {$in: event_ids}).fetch()
  else
    return []

# user template
Template.user.info = ->
  Meteor.users.findOne(Session.get("user_id"))

Template.user.user_events = ->
  Events.find(created_by: Session.get("user_id")).fetch()

Template.event.info = ->
  Events.findOne(Session.get("event_id"))

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
