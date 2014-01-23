window.events_at_penn ?= {}

window.events_at_penn.get_events = (criteria = {}, projection = {}) ->
  criteria = _.extend({to: {$gte: new Date()}}, criteria)

  skip = parseInt(Session.get("params")?.start) or 0
  projection = _.extend({sort: {from: 1}, limit: 10, skip: skip}, projection)

  Events.find(criteria, projection)

window.events_at_penn.serialize = (params) ->
  e = encodeURIComponent
  ("#{e k}=#{e v}" for k, v of params when k and v).join '&'

window.events_at_penn.DATE_FORMAT = "YYYY-MM-DD"
window.events_at_penn.TIME_FORMAT = "HH:mm"

# convert undefined, single category to array
fix_categories = (categories) ->
  if not _.isArray(categories)
    if categories?
      return [categories]
    else
      return []
  return categories


# convert undefined, single category to array
fix_categories = (categories) ->
  if not _.isArray(categories)
    if categories?
      return [categories]
    else
      return []
  return categories

window.events_at_penn.parse_event_from_form = (form) ->
  event = form.serializeObject()
  event.categories = fix_categories(event.categories)

  date_start = moment(event.date_start, events_at_penn.DATE_FORMAT)
  time_start = moment(event.time_start, events_at_penn.TIME_FORMAT)

  delete event['date_start']
  delete event['time_start']

  event.from = date_start
    .hour(time_start.hour())
    .minute(time_start.minute())
    .toDate()

  date_end = moment(event.date_end, events_at_penn.DATE_FORMAT)
  time_end = moment(event.time_end, events_at_penn.TIME_FORMAT)

  delete event['date_end']
  delete event['time_end']

  event.to = date_end
    .hour(time_end.hour())
    .minute(time_end.minute())
    .toDate()

  # Create unique id for each event (by title) for semantic URL
  # Simple English: Replaces spaces with dashes, lowercases title
  clean_title = event.name.replace(/\s+/g, '-').toLowerCase()
  latest_event = Events.find(
    {title_id:
      # Matches on other events with same clean_title but different title number
      # Ex:
      # clean_title: 'meeting-at-harnwell'
      # Matches: 'meeting-at-harnwell-10', 'meeting-at-harnwell-5'
      # Does not match 'best-meeting-at-harnwell-10', 'meeting-at-harnwell-2-2'
      # Simple English: match on clean_title-## (whole word)
      $regex: '^(' + clean_title + '-(\\d+))$'}
    {sort:
      timestamp: -1
    limit: 1})
    .fetch()[0]

  if latest_event
    # Find the terminating title number
    # Ex:
    # 'meeting-at-harnwell-15' -> '-15'
    # Simple English: match on -## at the end of a word
    r = new RegExp '(-(\\d+))$'
    suffix = r.exec(latest_event.title_id)[0]
    # Use substring to take dash prefix off
    title_id = parseInt(suffix.substring(1)) + 1
  else
    title_id = 1
  # Put title_id together from URL encoded clean_title and id (dash separated)
  event.title_id = encodeURIComponent(clean_title + '-' +  title_id)

  event.timestamp = new Date().getTime()

  return event

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

Template.show_or_edit_event.events
  'click .star': (e) ->
    event_id = $(e.currentTarget).data('event_id')
    Meteor.call "star_event", event_id
  'click .unstar': (e) ->
    event_id = $(e.currentTarget).data('event_id')
    Meteor.call "unstar_event", event_id

Template.show_or_edit_event.helpers
  'editing': (event_id) -> Session.equals('editing', event_id)

Template.event_info.helpers
  'info': -> Events.findOne(Session.get("event_id")) or {}
