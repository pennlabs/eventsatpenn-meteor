window.events_at_penn ?= {}


Template.new_event.helpers
  'empty_object': {}

Template.new_event.events
  'submit .create-event': (e) ->
    e.preventDefault()
    event = window.events_at_penn.parse_event_from_form $('.create-event')

    user = Meteor.user()
    event.creator = user._id
    event.creator_name = user.profile.name

    event_id = Events.insert(event)
    Meteor.call('create_event', event_id)
    Meteor.Router.to "/event/#{event_id}"

Template.pagination.helpers
  'prev_disabled': ->
    "disabled" unless Session.get("params")?.start
  'prev': ->
    params = Session.get("params")
    params.start = Math.max (parseInt params?.start or 0) - 10, 0
    "?#{window.events_at_penn.serialize params}"
  'next': ->
    params = Session.get("params")
    params.start = (parseInt params?.start or 0) + 10
    "?#{window.events_at_penn.serialize params}"