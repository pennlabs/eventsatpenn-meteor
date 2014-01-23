Template.search.helpers
  'events': ->
    params = Session.get("params") or {}
    q = params.q
    date = params.date
    categories = params.categories?.split('+').map decodeURIComponent

    opts = {$and: []}
    if q
      re = new RegExp("#{q}.*", 'i')
      q_query = {
        $or: [{name: re}, {description: re}, {categories: re}, {location: re}]
      }
      opts["$and"].push q_query
    if date
      date_query = {to: {$gte: moment(date).toDate()}}
      opts["$and"].push date_query
    if categories
      categories_query = {categories: {$in: categories}}
      opts["$and"].push categories_query

    opts = if opts["$and"].length then opts else {}
    window.events_at_penn.get_events(opts)
