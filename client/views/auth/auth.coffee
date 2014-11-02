Template.login.events
  'click .forgot-pass': (e) ->
    Session.set("button-msg")
    Session.set('forgot-pass', !Session.get('forgot-pass'))
  'submit #forgot-pass-form': (e) ->
    e.preventDefault()
    email = $('#forgot-pass-form').serializeObject().email
    if email
      Accounts.forgotPassword {email}, (err) ->
        msg = err?.reason or "Email sent"
        Session.set('button-msg', "(#{msg})")
        setTimeout (-> Session.set "button-msg"), 2000 # should clear old timeout
  'submit #login-form': (e) ->
    e.preventDefault()
    creds = $('#login-form').serializeObject()
    Meteor.loginWithPassword creds.email, creds.password, (err) ->
      if err
        Session.set("button-msg", "(#{err.reason})")
        setTimeout (-> Session.set "button-msg"), 2000 # should clear old timeout
      else
        Meteor.Router.to '/'
  'click .fb': (e) ->
    Meteor.loginWithFacebook {}, (err) ->
      if not err
        Meteor.call "create_fb_user", Meteor.userId()
        Meteor.Router.to '/'

Template.login.helpers
  'forgot': -> !!Session.get('forgot-pass')
  'button_msg': ->
    if Session.get("button-msg")?
      return Session.get("button-msg")
    else if Session.get("forgot-pass")
      return "Reset Password"
    else
      return "Login"
  'button_class': -> if Session.get("button-msg") then "error" else ""
