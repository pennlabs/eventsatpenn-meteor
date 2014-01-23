Meteor.publish "userData", ->
  # decides fields that are visible to the client
  return Meteor.users.find @userId,
    fields:
      _id: true
      emails: true
      events: true
      event_queue: true
      followers: true
      following: true
