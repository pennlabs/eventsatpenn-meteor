Template.settingsButton.events
  'click .settings': (e) ->
    e.preventDefault()
    Meteor.Router.to "/settings"
