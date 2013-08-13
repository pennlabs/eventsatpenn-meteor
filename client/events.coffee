Meteor.subscribe("userData")

$.fn.serializeObject = ->
  o = {}
  a = @serializeArray()
  $.each a, ->
    if o[@name] isnt undefined
      o[@name] = [o[@name]]  unless o[@name].push
      o[@name].push @value or ""
    else
      o[@name] = @value or ""
  return o

Template.topbar.events
  'click .logout': (e) -> Meteor.logout()

Template.login.events
  'submit #login-form': (e) ->
    e.preventDefault()
    creds = $('#login-form').serializeObject()
    Meteor.loginWithPassword creds.email, creds.password, (err) ->
      if not err
        Meteor.Router.to '/'
  'submit #register-form': (e) ->
    e.preventDefault()
    user = $('#register-form').serializeObject()
    if user.password == user.confirm
      Accounts.createUser(
        email: user.email
        password: user.password
        profile:
          first_name: user.first_name
          last_name: user.last_name
          description: user.description
          events: []
          event_queue: []
          followers: []
          following: []
      , (err) ->
        if not err
          Meteor.call "follow_user", Meteor.userId()
          Meteor.Router.to '/'
      )

Template.events.events
  'submit .search-form': (e) ->
    e.preventDefault()
    q = $('#search-term').val()
    console.log q

Template.new.events
  'submit .create-event': (e) ->
    e.preventDefault()
    event = $('.create-event').serializeObject()

    user = Meteor.user()
    event.creator = user._id
    event.creator_name = user.profile.first_name + " " + user.profile.last_name

    event_id = Events.insert(event)
    Meteor.call('create_event', event_id)
    Meteor.Router.to "/event/#{event_id}"

Template.user.events
  'click .follow': (e) ->
    e.preventDefault()
    Meteor.call("follow_user", Session.get("user_id"))
  'click .unfollow': (e) ->
    e.preventDefault()
    console.log "unfollowed"

Template.all.all_events = -> Events.find().fetch()

# events template
Template.events.event_queue = ->
  if Meteor.user()
    event_ids = Meteor.user().profile.event_queue or []
    return Events.find(_id: {$in: event_ids}).fetch()
  else
    return []

# user template
Template.user.info = ->
  Meteor.users.findOne(Session.get("user_id")) or {}

Template.user.user_events = ->
  Events.find(creator: Session.get("user_id")).fetch() or []

Template.user.following = ->
  Meteor.user().profile.following.indexOf(Session.get("user_id")) > -1

Template.event_info.info = ->
  Events.findOne(Session.get("event_id")) or {}

Meteor.Router.add
  '/': 'events'
  '/all': 'all'
  '/new': 'new'
  '/login': 'login'
  '/event/:event_id': (event_id) ->
    Session.set("event_id", event_id)
    return 'event_info'
  '/user/:user_id': (user_id) ->
    Session.set("user_id", user_id)
    return 'user'
