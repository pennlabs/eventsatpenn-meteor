window.events_at_penn ?= {}

Template.new_event.helpers
  'empty_object': {}

Template.new_event.events
  'submit .create-event': (e) ->
    e.preventDefault()
    event = window.events_at_penn.parse_event_from_form $('.create-event')
    Meteor.call('create_event', event, (error, id) ->
      if (error)
        return alert(error.reason)
      Meteor.Router.to "/event/#{event.title_id}"
    )
  'click .cancel-event': (e) ->
    e.preventDefault()
    Meteor.Router.to '/'
