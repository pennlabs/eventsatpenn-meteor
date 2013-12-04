window.events_at_penn ?= {}


# events template
Template.events.helpers
  'event_queue': ->
    if Meteor.user()
      event_ids = Meteor.user().profile.event_queue or []
    else
      event_ids = []
      not_flat = Meteor.users.find("profile.admin": true).map (admin) -> admin?.profile?.events or []
      event_ids = event_ids.concat.apply(event_ids, not_flat)
    window.events_at_penn.get_events({_id: {$in: event_ids}})
