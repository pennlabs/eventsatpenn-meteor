
Template.login.events
  'submit #login-form': (e) ->
    e.preventDefault()
    creds = $('#login-form').serializeObject()
    Meteor.loginWithPassword creds.email, creds.password, (err) ->
      if err
        Session.set("login_error", "(#{err.reason})")
        setTimeout (-> Session.set "login_error"), 2000
      else
        Meteor.Router.to '/'
  'submit #register-form': (e) ->
    e.preventDefault()
    user = $('#register-form').serializeObject()
    if user.password and user.password == user.confirm
      admin_ids = Meteor.users.find("profile.admin": true).map (admin) -> admin._id
      admin_event_ids = Events.find(creator: {$in: admin_ids}).map (event) -> event._id

      Accounts.createUser(
        email: user.email
        password: user.password
        profile:
          name: user.name
          description: user.description
          events: []
          event_queue: admin_event_ids
          followers: []
          following: admin_ids
      , (err) ->
        if not err
          Meteor.call "follow_user", Meteor.userId()
          Meteor.Router.to '/'
      )
    else
      alert "Passwords do not match"
  'click .fb': (e) ->
    Meteor.loginWithFacebook {}, (err) ->
      if not err
        Meteor.call "create_fb_user", Meteor.userId()
        Meteor.Router.to '/'

Template.login.helpers
  'login_error': -> Session.get("login_error") or "Login"
  'login_class': -> if Session.get("login_error") then "error" else ""