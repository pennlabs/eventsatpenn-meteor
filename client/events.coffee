Template.events.events
  'submit .search-form': (e) ->
    e.preventDefault()
    q = $('#search-term').val()
    console.log q

Template.new.events
  'submit .create-event': (e) ->
    e.preventDefault()
    console.log "form submitted"

Meteor.pages
  '/': {to: 'events', as: 'root'}
  '/new': {to: 'new', as: 'new_event'}
