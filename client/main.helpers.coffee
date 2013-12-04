

window.events_at_penn.get_events = (criteria = {}, projection = {}) ->
  criteria = _.extend({to: {$gte: new Date()}}, criteria)

  skip = parseInt(Session.get("params")?.start) or 0
  projection = _.extend({sort: {from: 1}, limit: 10, skip: skip}, projection)

  Events.find(criteria, projection)
