Template.all.helpers
  'all_events': -> window.events_at_penn.get_events(starred: {$exists: false})
  'featured_events': -> window.events_at_penn.get_events({starred: {$exists: true}}, {skip: 0, limit: 10})
