

Template.show_user.events
  'click .follow': (e) ->
    e.preventDefault()
    Meteor.call("follow_user", Session.get("user_id"))
  'click .unfollow': (e) ->
    e.preventDefault()
    Meteor.call("unfollow_user", Session.get("user_id"))

# user template
Template.show_user.helpers
  'info': ->
    Meteor.users.findOne(Session.get("user_id")) or {}
  'mine': ->
    Meteor.user()._id == Session.get("user_id")
  'user_events': ->
    window.events_at_penn.get_events(creator: Session.get("user_id")) or []
  'following': ->
    Meteor.user()?.profile?.following.indexOf(Session.get("user_id")) > -1
