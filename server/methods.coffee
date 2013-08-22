Meteor.methods
  create_event: (event_id) ->
    Meteor.users.update(Meteor.userId(), {$push: {"profile.events": event_id}})
    followers = Meteor.user().profile.followers or []
    if followers.length
      Meteor.users.update(_id: {$in: followers}, {$push: {"profile.event_queue": event_id}})

  # pulling events, pulls all occurences of that event out,
  # so if the user created the event or follows someone who created it,
  # it will get pulled from his/her event_queue
  #
  # when a user destroys a starred event, it still exists in the admins' events
  # to solve it, pull from everywhere IF you're the creator?
  # Meteor.users.update({}, {$pull: {"profile.events": event_id}})
  # alternatively, have a different method to un-star events as opposed to destroy
  destroy_event: (event_id) ->
    Events.remove(event_id)
    Meteor.users.update(Meteor.userId(), {$pull: {"profile.events": event_id}})
    followers = Meteor.user().profile.followers or []
    if followers.length
      Meteor.users.update(_id: {$in: followers}, {$pull: {"profile.event_queue": event_id}})

  star_event: (event_id) ->
    Event.update(event_id, {$set: {starred: {by: Meteor.user().profile.full_name, by_id: Meteor.userId()}}})

  unstar_event: (event_id) ->
    Event.update(event_id, {$unset: {starred: 1}})

  follow_user: (user_id) ->
    Meteor.users.update(Meteor.userId(), {$push: {"profile.following": user_id}})
    Meteor.users.update(user_id, {$push: {"profile.followers": Meteor.userId()}})
    event_ids = Meteor.users.findOne(user_id).profile.events or []
    if event_ids.length
      Meteor.users.update(Meteor.userId(), {$pushAll: {"profile.event_queue": event_ids}})

  # only push and pull are different
  unfollow_user: (user_id) ->
    Meteor.users.update(Meteor.userId(), {$pull: {"profile.following": user_id}})
    Meteor.users.update(user_id, {$pull: {"profile.followers": Meteor.userId()}})
    event_ids = Meteor.users.findOne(user_id).profile.events or []
    if event_ids.length
      Meteor.users.update(Meteor.userId(), {$pullAll: {"profile.event_queue": event_ids}})
