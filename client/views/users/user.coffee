

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
  'user_events': ->
    window.events_at_penn.get_events(creator: Session.get("user_id")) or []
  'following': ->
    Meteor.user()?.profile?.following.indexOf(Session.get("user_id")) > -1
  'facebook_url': ->
    user = Meteor.user()
    if user.services.facebook
      user.services.facebook.link
    else
      false
