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
  'submit .search': (e) ->
    e.preventDefault()
    q = $('#searchbox').val()
    Meteor.Router.to "/search/#{encodeURIComponent(q)}"

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
      admin_ids = Meteor.users.find("profile.admin": true).map (admin) -> admin._id
      admin_event_ids = Events.find(creator: {$in: admin_ids}).map (event) -> event._id

      Accounts.createUser(
        email: user.email
        password: user.password
        profile:
          full_name: user.full_name
          description: user.description
          events: []
          event_queue: admin_event_ids
          followers: []
          following: admin_ids
      , (err) ->
        if not err
          Meteor.call "follow_user", Meteor.userId()
          Meteor.Router.to '/'
      )

Template.new.events
  'submit .create-event': (e) ->
    e.preventDefault()
    event = $('.create-event').serializeObject()

    user = Meteor.user()
    event.creator = user._id
    event.creator_name = user.profile.full_name

    event_id = Events.insert(event)
    Meteor.call('create_event', event_id)
    Meteor.Router.to "/event/#{event_id}"

Template.user.events
  'click .follow': (e) ->
    e.preventDefault()
    Meteor.call("follow_user", Session.get("user_id"))
  'click .unfollow': (e) ->
    e.preventDefault()
    Meteor.call("unfollow_user", Session.get("user_id"))

Template.event.events
  'click .promote': (e) ->
    event_id = $(e.currentTarget).data('event_id')
    Meteor.call "create_event", event_id
  'click .unpromote': (e) ->
    event_id = $(e.currentTarget).data('event_id')
    Meteor.call "destroy_event", event_id

Template.event.helpers
  'admin': -> Meteor.user()?.profile?.admin
  'starred': (event_id) ->
    console.log event_id
    Meteor.user()?.profile?.events.indexOf(event_id) > -1

Template.all.helpers
  'all_events': -> Events.find().fetch()

# events template
Template.events.helpers
  'event_queue': ->
    if Meteor.user()
      event_ids = Meteor.user().profile.event_queue or []
    else
      event_ids = []
      not_flat = Meteor.users.find("profile.admin": true).map (admin) -> admin?.profile?.events or []
      event_ids = event_ids.concat.apply(event_ids, not_flat)
    Events.find(_id: {$in: event_ids}).fetch()

# user template
Template.user.helpers
  'info': ->
    Meteor.users.findOne(Session.get("user_id")) or {}
  'user_events': ->
    Events.find(creator: Session.get("user_id")).fetch() or []
  'following': ->
    Meteor.user()?.profile?.following.indexOf(Session.get("user_id")) > -1

Template.event_info.helpers
  'info': ->
    Events.findOne(Session.get("event_id")) or {}

Template.search.found_events = ->
  q = Session.get("q")
  re = new RegExp("#{q}.*")
  Events.find(name: re).fetch()
