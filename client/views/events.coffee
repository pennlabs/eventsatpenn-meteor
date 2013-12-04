window.events_at_penn ?= {}

serialize = window.events_at_penn.serialize

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

Template.show_or_edit_event.events
  'click .star': (e) ->
    event_id = $(e.currentTarget).data('event_id')
    Meteor.call "star_event", event_id
  'click .unstar': (e) ->
    event_id = $(e.currentTarget).data('event_id')
    Meteor.call "unstar_event", event_id

Template.show_or_edit_event.helpers
  'editing': (event_id) -> Session.equals('editing', event_id)

Template.all.helpers
  'all_events': -> window.events_at_penn.get_events(starred: {$exists: false})
  'featured_events': -> window.events_at_penn.get_events({starred: {$exists: true}}, {skip: 0, limit: 10})

Template.event_info.helpers
  'info': ->
    Events.findOne(Session.get("event_id")) or {}

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
    window.events_at_penn.get_events(opts)
