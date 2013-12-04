window.events_at_penn ?= {}


Template.edit_event.events
  'submit .create-event': (e) ->
    e.preventDefault()
    event = window.events_at_penn.parse_event_from_form $('.create-event')
    Events.update(event.id, $set: event)
    Session.set('editing', null)
