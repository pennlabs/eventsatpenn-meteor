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

moment.lang 'en',
  calendar:
    lastWeek: '[last] dddd [at] LT',
    lastDay: '[Yesterday,] LT',
    sameDay: '[Today,] LT',
    nextDay: '[Tomorrow,] LT',
    nextWeek: 'dddd, LT',
    sameElse: 'dddd, L[,] LT'

DATE_FORMAT = "YYYY-MM-DD"
TIME_FORMAT = "HH:mm"

serialize = (params) ->
  e = encodeURIComponent
  ("#{e k}=#{e v}" for k, v of params when k and v).join '&'

# convert undefined, single category to array
fix_categories = (categories) ->
  if not _.isArray(categories)
    if categories?
      return [categories]
    else
      return []
  return categories

parse_event_from_form = (form) ->
  event = form.serializeObject()
  event.categories = fix_categories(event.categories)

  date_start = moment(event.date_start, DATE_FORMAT)
  time_start = moment(event.time_start, TIME_FORMAT)

  delete event['date_start']
  delete event['time_start']

  event.from = date_start
    .hour(time_start.hour())
    .minute(time_start.minute())
    .toDate()

  date_end = moment(event.date_end, DATE_FORMAT)
  time_end = moment(event.time_end, TIME_FORMAT)

  delete event['date_end']
  delete event['time_end']

  event.to = date_end
    .hour(time_end.hour())
    .minute(time_end.minute())
    .toDate()

  return event

get_events = (criteria = {}, projection = {}) ->
  criteria = _.extend({to: {$gte: new Date()}}, criteria)

  skip = parseInt(Session.get("params")?.start) or 0
  projection = _.extend({sort: {from: 1}, limit: 10, skip: skip}, projection)

  Events.find(criteria, projection)

Template.sidebar.helpers
  'categories': Categories
  'escape_category': encodeURIComponent
  'checked': (category) ->
    categories = Session.get("params")?.categories?.split("+").map decodeURIComponent
    if _.contains categories, category then "checked" else ""
  'after_date': -> Session.get("params")?.date or new Date().toJSON().slice(0,10)

Template.sidebar.events
  'click .sidebar-fold': (e) -> $('.sidebar').toggleClass('folded')
  'change .category-checkbox': (e) ->
    categories = $('.category-checkbox:checked').map(-> @value).toArray()
    if categories.length
      params = Session.get("params") or {}
      params.categories = categories.join('+')
      Meteor.Router.to "/search?#{serialize params}"
    else
      # Session.set("params")
      Meteor.Router.to "/"
  'change .date': (e) ->
    date = $(e.currentTarget).val()
    if date
      params = Session.get("params") or {}
      params.date = date
      Meteor.Router.to "/search?#{serialize params}"

Template.topbar.helpers
  'q': -> Session.get("params")?.q

Template.topbar.events
  'click .logout': (e) -> Meteor.logout()
  'submit .search': (e) ->
    e.preventDefault()
    params = Session.get("params") or {}
    params.q = $('#searchbox').val()
    Meteor.Router.to "/search?#{serialize params}"

Template.topbar.rendered = ->
  if !window.foundation?
    $(document).foundation -> window.foundation = true

  if !window._gaq?
    window._gaq = []
    _gaq.push(['_setAccount', 'UA-12991053-1'])
    _gaq.push(['_trackPageview'])
    (->
      ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true
      gajs = '.google-analytics.com/ga.js'
      ga.src = if 'https:' is document.location.protocol then 'https://ssl'+gajs else 'http://www'+gajs
      s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s)
    )()

Template.login.events
  'submit #login-form': (e) ->
    e.preventDefault()
    creds = $('#login-form').serializeObject()
    Meteor.loginWithPassword creds.email, creds.password, (err) ->
      if err
        Session.set("login_error", "(#{err.reason})")
        setTimeout (-> Session.set "login_error"), 2000
      else
        Meteor.Router.to '/'
  'submit #register-form': (e) ->
    e.preventDefault()
    user = $('#register-form').serializeObject()
    if user.password and user.password == user.confirm
      admin_ids = Meteor.users.find("profile.admin": true).map (admin) -> admin._id
      admin_event_ids = Events.find(creator: {$in: admin_ids}).map (event) -> event._id

      Accounts.createUser(
        email: user.email
        password: user.password
        profile:
          name: user.name
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
  'click .fb': (e) ->
    Meteor.loginWithFacebook {}, (err) ->
      if not err
        Meteor.call "create_fb_user", Meteor.userId()
        Meteor.Router.to '/'


Template.login.helpers
  'login_error': -> Session.get("login_error") or "Login"
  'login_class': -> if Session.get("login_error") then "error" else ""

Template.new.helpers
  'empty_object': {}

Template.new.events
  'submit .create-event': (e) ->
    e.preventDefault()
    event = parse_event_from_form $('.create-event')

    user = Meteor.user()
    event.creator = user._id
    event.creator_name = user.profile.name

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

Template.pagination.helpers
  'prev_disabled': ->
    "disabled" unless Session.get("params")?.start
  'prev': ->
    params = Session.get("params")
    params.start = Math.max (parseInt params?.start or 0) - 10, 0
    "?#{serialize params}"
  'next': ->
    params = Session.get("params")
    params.start = (parseInt params?.start or 0) + 10
    "?#{serialize params}"

Template.event.events
  'click .star': (e) ->
    event_id = $(e.currentTarget).data('event_id')
    Meteor.call "star_event", event_id
  'click .unstar': (e) ->
    event_id = $(e.currentTarget).data('event_id')
    Meteor.call "unstar_event", event_id

Template.event.helpers
  'editing': (event_id) -> Session.equals('editing', event_id)

Template.show_event.events
  'click .edit': (e) ->
    e.preventDefault()
    event_id = $(e.currentTarget).data('event_id')
    Session.set('editing', event_id)
  'click .delete': (e) ->
    e.preventDefault()
    event_id = $(e.currentTarget).data('event_id')
    Meteor.call "destroy_event", event_id

Template.edit_event.events
  'submit .create-event': (e) ->
    e.preventDefault()
    event = parse_event_from_form $('.create-event')
    Events.update(event.id, $set: event)
    Session.set('editing', null)

Template.show_event.helpers
  'admin': -> Meteor.user()?.profile?.admin
  'escape_category': encodeURIComponent
  'mine': ->
    Meteor.user()?.profile?.events.indexOf(@_id) > -1
  'when': ->
    "#{moment(@from).format('lll')} - #{moment(@to).format('lll')}"
  'parse': (d) ->
    console.log d
    regex = /((http\:\/\/|https\:\/\/)|(www\.))+(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/g
    d = d.replace regex, (value) ->
      value = value.toLowerCase()
      m = value.match /^([a-z]+:\/\/)/
      if m
        nice = value.replace m[1], ""
        url = value
      else
        nice = value
        url = "http://#{nice}"
      # remove trailing . or ; from url
      url = url.replace /(\.|;)$/, ""
      return "<a target='_blank' href='#{url}'>#{nice}</a>"
    return new Handlebars.SafeString(d)

Template.all.helpers
  'all_events': -> get_events(starred: {$exists: false})
  'featured_events': -> get_events({starred: {$exists: true}}, {skip: 0, limit: 10})

# events template
Template.events.helpers
  'event_queue': ->
    if Meteor.user()
      event_ids = Meteor.user().profile.event_queue or []
    else
      event_ids = []
      not_flat = Meteor.users.find("profile.admin": true).map (admin) -> admin?.profile?.events or []
      event_ids = event_ids.concat.apply(event_ids, not_flat)
    get_events({_id: {$in: event_ids}})

# user template
Template.user.helpers
  'info': ->
    Meteor.users.findOne(Session.get("user_id")) or {}
  'user_events': ->
    get_events(creator: Session.get("user_id")) or []
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
    services = ["COMPUTER", "DROPBOX", "FACEBOOK", "FLICKR", "GOOGLE_DRIVE", "SKYDRIVE", "IMAGE_SEARCH", "INSTAGRAM", "URL", "WEBCAM"]
    filepicker.setKey("AA_3IkmAOQX2Drld5QS9qz")
    filepicker.pickAndStore {services: services, extensions: [".png", ".jpg", ".jpeg"]},
      {location: 'S3'}, on_success, on_error

Template.event_form.helpers
  'cats': (categories) ->
    Categories.map (category) -> {name: category, categories}
  'selected': ({name, categories}) ->
    if _.contains categories, name then "selected" else ""
  'date_start': ->
    return moment(@from).format(DATE_FORMAT)
  'date_end': ->
    return moment(@to).format(DATE_FORMAT)
  'time_start': ->
    return moment(@from).format(TIME_FORMAT)
  'time_end': ->
    return moment(@to).format(TIME_FORMAT)


Template.event_form.rendered = -> $(".categories-chooser").chosen()

Template.search.helpers
  'events': ->
    params = Session.get("params") or {}
    q = params.q
    date = params.date
    categories = params.categories?.split('+').map decodeURIComponent

    opts = {$and: []}
    if q
      re = new RegExp("#{q}.*", 'i')
      q_query = {$or: [{name: re}, {description: re}, {categories: re}, {location: re}]}
      opts["$and"].push q_query
    if date
      date_query = {to: {$gte: moment(date).toDate()}}
      opts["$and"].push date_query
    if categories
      categories_query = {categories: {$in: categories}}
      opts["$and"].push categories_query

    opts = if opts["$and"].length then opts else {}
    get_events(opts)
