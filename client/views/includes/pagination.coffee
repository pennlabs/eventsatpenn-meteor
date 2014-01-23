Template.pagination.helpers
  'prev_disabled': ->
    "disabled" unless Session.get("params")?.start
  'prev': ->
    params = Session.get("params")
    params.start = Math.max (parseInt params?.start or 0) - 10, 0
    "?#{window.events_at_penn.serialize params}"
  'next': ->
    params = Session.get("params")
    params.start = (parseInt params?.start or 0) + 10
    "?#{window.events_at_penn.serialize params}"
