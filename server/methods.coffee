Meteor.methods
  create_event: (event_id) ->
    Meteor.users.update(Meteor.userId(), {$push: {"profile.events": event_id}})
    followers = Meteor.user().profile.followers or []
    Meteor.users.update(_id: {$in: followers}, {$push: {"profile.event_queue": event_id}})

  follow_user: (user_id) ->
    Meteor.users.update(Meteor.userId(), {$push: {"profile.following": user_id}})
    event_ids = Meteor.users.findOne(user_id).profile.events or []
    Meteor.users.update(Meteor.userId(), {$push: {"profile.event_queue": event_ids}})
