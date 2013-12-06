window.events_at_penn ?= {}


window.events_at_penn.get_events = (criteria = {}, projection = {}) ->
  criteria = _.extend({to: {$gte: new Date()}}, criteria)

  skip = parseInt(Session.get("params")?.start) or 0
  projection = _.extend({sort: {from: 1}, limit: 10, skip: skip}, projection)

  Events.find(criteria, projection)

window.events_at_penn.serialize = (params) ->
  e = encodeURIComponent
  ("#{e k}=#{e v}" for k, v of params when k and v).join '&'

DATE_FORMAT = "YYYY-MM-DD"
TIME_FORMAT = "HH:mm"

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
