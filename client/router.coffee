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
Router.setTemplateNameConverter(_.identity)

Router.map ->
  @route 'all',
    path: '/'
    onBeforeAction: ->
      Session.set('params', parse_params @params)
      this.next()
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
      this.next()
  @route 'show_user',
    path: '/user/:user_id'
    onBeforeAction: ->
      Session.set('user_id', @params.user_id)
      this.next()
  @route 'edit_user', path: '/settings'
  @route 'search',
    onBeforeAction: ->
      Session.set('params', parse_params @params)
      this.next()

requireLogin = ->
  if not Meteor.user()
    @render 'login'
  else
    this.next()

Router.onBeforeAction requireLogin, only: [
  'new_event',
  'edit_user'
]
