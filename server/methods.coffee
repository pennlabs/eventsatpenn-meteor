Meteor.methods
  create_event: (event_id) ->
    Meteor.users.update(Meteor.userId(), {$push: {events: event_id}})
    followers = Meteor.user().followers or []
    Meteor.users.update(_id: {$in: followers}, {$push: {event_queue: event_id}})

  follow_user: (user_id) ->
    Meteor.users.update(Meteor.userId(), {$push: {following: user_id}})
    event_ids = Meteor.users.findOne(user_id)
    Meteor.users.update(Meteor.userId(), {$push: {event_queue: event_ids}})
