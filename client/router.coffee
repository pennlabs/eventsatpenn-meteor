parse_params = (params_object) ->
  params = {}
  keys = Object.keys(params_object)
  # First key is hash
  keys.shift()
  for prp in keys
    params[prp] = params_object[prp]
  params

Router.configure
  layoutTemplate: 'layout'

Router.map ->
  @route 'all',
    path: '/'
    onBeforeAction: ->
      Session.set('params', parse_params @params)
  @route 'new_event', path: '/new'
  @route 'login'
  @route 'event_info',
    path: '/event/:title_id'
    onBeforeAction: ->
      title_id = @params.title_id
      event_id = Events.findOne(title_id: encodeURIComponent(title_id))
      # Backwards compatible: if title_id is not found, assume the url is an event_id
      if not event_id
        event_id = title_id
      Session.set("event_id", event_id)
  @route 'show_user',
    path: '/user/:user_id'
    onBeforeAction: ->
      Session.set('user_id', @params.user_id)
  @route 'edit_user', path: '/settings'
  @route 'search',
    onBeforeAction: ->
      Session.set('params', parse_params @params)

requireLogin = ->
  if not Meteor.user()
    @render 'login'
    pause()

Router.onBeforeAction requireLogin, only: [
  'new_event',
  'edit_user'
]
