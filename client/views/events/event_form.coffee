window.events_at_penn ?= {}

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
