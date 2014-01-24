Template.sidebar.helpers
  'categories': -> Categories
  'escape_category': encodeURIComponent
  'checked': (category) ->
    categories = Session.get("params")?.categories?.split("+").map decodeURIComponent
    if _.contains categories, category then "checked" else ""
  'after_date': -> Session.get("params")?.date or new Date().toJSON().slice(0,10)

Template.sidebar.events
  'click .sidebar-fold': (e) -> $('.sidebar').toggleClass('folded')
  'change .category-checkbox': (e) ->
    categories = $('.category-checkbox:checked').map(-> @value).toArray()
    if categories.length
      params = Session.get("params") or {}
      params.categories = categories.join('+')
      Meteor.Router.to "/search?#{window.events_at_penn.serialize params}"
    else
      # Session.set("params")
      Meteor.Router.to "/"
  'change .date': (e) ->
    date = $(e.currentTarget).val()
    if date
      params = Session.get("params") or {}
      params.date = date
      Meteor.Router.to "/search?#{window.events_at_penn.serialize params}"
