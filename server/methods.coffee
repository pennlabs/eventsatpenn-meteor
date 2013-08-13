Meteor.methods
  create_event: (event_id) ->
    Meteor.users.update(Meteor.userId(), {$push: {"profile.events": event_id}})
    followers = Meteor.user().profile.followers or []
    if followers.length
      Meteor.users.update(_id: {$in: followers}, {$push: {"profile.event_queue": event_id}})

  follow_user: (user_id) ->
    Meteor.users.update(Meteor.userId(), {$push: {"profile.following": user_id}})
    Meteor.users.update(user_id, {$push: {"profile.followers": Meteor.userId()}})
    event_ids = Meteor.users.findOne(user_id).profile.events or []
    console.log event_ids
    if event_ids.length
      Meteor.users.update(Meteor.userId(), {$pushAll: {"profile.event_queue": event_ids}})
