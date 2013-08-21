Meteor.subscribe("userData")

$.fn.serializeObject = ->
  o = {}
  a = @serializeArray()
  $.each a, ->
    if o[@name] isnt undefined
      o[@name] = [o[@name]] unless o[@name].push
      o[@name].push @value or ""
    else
      o[@name] = @value or ""
  return o

moment.lang('en', {
    calendar : {
        lastWeek : '[last] dddd [at] LT',
        lastDay : '[Yesterday,] LT',
        sameDay : '[Today,] LT',
        nextDay : '[Tomorrow,] LT',
        nextWeek : 'dddd, LT',
        sameElse : 'dddd, L[,] LT'
    }
})

# convert undefined, single category to array
fix_categories = (categories) ->
  if not _.isArray(categories)
    if categories?
      return [categories]
    else
      return []
  return categories

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
    else
      alert "Passwords do not match"

Template.new.helpers
  'empty_object': {}

Template.new.events
  'submit .create-event': (e) ->
    e.preventDefault()
    event = $('.create-event').serializeObject()
    event.categories = fix_categories(event.categories)

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
  'click .star': (e) ->
    event_id = $(e.currentTarget).data('event_id')
    Meteor.call "create_event", event_id
  'click .unstar': (e) ->
    event_id = $(e.currentTarget).data('event_id')
    Meteor.call "destroy_event", event_id

Template.event.helpers
  'editing': (event_id) -> Session.equals('editing', event_id)

Template.show_event.events
  'click .edit': (e) ->
    e.preventDefault()
    event_id = $(e.currentTarget).data('event_id')
    Session.set('editing', event_id)

Template.edit_event.events
  'submit .create-event': (e) ->
    e.preventDefault()
    event = $('.create-event').serializeObject()
    event.categories = fix_categories(event.categories)
    Events.update(event.id, $set: event)
    Session.set('editing', null)

Template.show_event.helpers
  'admin': -> Meteor.user()?.profile?.admin
  'escape_category': encodeURIComponent
  'starred': ->
    Meteor.user()?.profile?.events.indexOf(@_id) > -1
  'mine': ->
    Meteor.user()?.profile?.events.indexOf(@_id) > -1
  'when': ->
    dateStart = moment(@date, "YYYY-MM-DD")
    timeStart = moment(@time_start, "hh-mm")
    timeEnd = moment(@time_end, "hh-mm")
    start = dateStart
    start.hour(timeStart.hour())
    start.calendar() + " - " + timeEnd.format("h:mm A")

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
    Events.find({_id: {$in: event_ids}}, {sort: {date: 1, time_start: 1}}).fetch()

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

Template.event_form.events
  'click .filepicker': (e) ->
    on_success = (blobs) ->
      image = if blobs.length then blobs[0] else {}
      $('.create-event label.filename').text image.filename
      $('.create-event input[name=image_url]').val image.url
    on_error = (error) -> console.log error
    filepicker.setKey("AA_3IkmAOQX2Drld5QS9qz")
    filepicker.pickAndStore mimetype: 'image/*', location: 'S3', on_error, on_success

Template.event_form.helpers
  'cats': Categories
  'is_selected': (category, categories) ->
    if categories?.indexOf(category) > -1
      return "selected"
    else
      return ""

Template.event_form.rendered = ->
  $(".categories-chooser").chosen()

Template.category.helpers
  'events': -> Events.find(categories: Session.get "category").fetch()

Template.search.found_events = ->
  q = Session.get("q")
  re = new RegExp("#{q}.*")
  Events.find(name: re).fetch()
