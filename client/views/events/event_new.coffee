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
