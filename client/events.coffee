Template.events.greeting = -> "Welcome to vents."

Template.events.events
  'click input': ->
      console.log("You pressed the button")

Template.new.events
  'submit': (e) ->
    console.log "form submitted"

Meteor.pages
  '/': {to: 'events', as: 'root'}
  '/new': {to: 'new', as: 'new_event'}
