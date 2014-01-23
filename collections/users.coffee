Meteor.users.allow
  update: (userId, user, fields, modifier) ->
    if user._id == userId
      Meteor.users.update(userId, modifier)
      return true
    return false

Meteor.methods
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

  create_fb_user: (user_id) ->
    exists = {$exists: false}
    admin_ids = Meteor.users.find("profile.admin": true).map (admin) -> admin._id
    admin_event_ids = Events.find(creator: {$in: admin_ids}).map (event) -> event._id

    Meteor.users.update({
      _id: user_id
      "profile.events": exists
      "profile.event_queue": exists
      "profile.followers": exists
      "profile.following": exists
    }, {$set: {
      "profile.events": []
      "profile.event_queue": admin_event_ids
      "profile.followers": []
      "profile.following": admin_ids.concat(user_id)
    }})
