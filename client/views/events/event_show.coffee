window.events_at_penn ?= {}


# aiming for four lines
MAX_EVENT_DESCRIPTION_HEIGHT = 120

Template.show_event.events
  'click .edit': (e) ->
    e.preventDefault()
    event_id = $(e.currentTarget).data('event_id')
    Session.set('editing', event_id)
  'click .delete': (e) ->
    e.preventDefault()
    event_id = $(e.currentTarget).data('event_id')
    Meteor.call "destroy_event", event_id


Template.show_event.rendered = (y) ->
  $description = $(@find('.event-description'))
  if (Meteor.Router.page() is "all" and $description.height() > MAX_EVENT_DESCRIPTION_HEIGHT)
    $description.dotdotdot(
      wrap: 'word',
      fallbackToLetter: true,
      after: 'a.read-more',
      watch: true,
      height: MAX_EVENT_DESCRIPTION_HEIGHT,
    )
  else
    $read_more = $(@find('a.read-more'))
    $read_more.hide()

Template.show_event.helpers
  'admin': -> Meteor.user()?.profile?.admin

  'escape_category': encodeURIComponent

  'mine': ->
    Meteor.user()?.profile?.events.indexOf(@_id) > -1

  'when': ->
    "#{moment(@from).format('lll')} - #{moment(@to).format('lll')}"

  'url': ->
    text = encodeURIComponent(@name)
    from = moment(@from)
      .toISOString()
      .replace(/[\-\.\:]/g, '')
      .replace('000Z', 'Z')
    to = moment(@to)
      .toISOString()
      .replace(/[\-\.\:]/g, '')
      .replace('000Z', 'Z')
    details = encodeURIComponent(@description)
    location = encodeURIComponent(@location)
    url =
      "http://www.google.com/calendar/event?action=TEMPLATE&text=" +
      text +
      "&dates=" +
      from +
      "/" +
      to +
      "&details=" +
      details +
      "&location=" +
      location +
      "&trp=true&sprop=events%40penn&sprop=name:eventsatpenn.com"
    url


  'parse': (description) ->
    regex = /((http\:\/\/|https\:\/\/)|(www\.))+(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/g
    description = description.replace regex, (value) ->
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
    return new Handlebars.SafeString(description)
