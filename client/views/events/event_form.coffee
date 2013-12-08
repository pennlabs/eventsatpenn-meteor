window.events_at_penn ?= {}

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
    return moment(@from).format(events_at_penn.DATE_FORMAT)
  'date_end': ->
    return moment(@to).format(events_at_penn.DATE_FORMAT)
  'time_start': ->
    return moment(@from).format(events_at_penn.TIME_FORMAT)
  'time_end': ->
    return moment(@to).format(events_at_penn.TIME_FORMAT)

Template.event_form.rendered = -> $(".categories-chooser").chosen()
