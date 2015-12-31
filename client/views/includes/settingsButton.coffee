Template.settingsButton.events
  'click .settings': (e) ->
    e.preventDefault()
    Router.go "/settings"
