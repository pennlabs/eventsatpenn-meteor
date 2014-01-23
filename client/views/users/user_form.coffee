

Template.user_form.events
  'submit': (e) ->
    e.preventDefault()
    user = $('#register-form').serializeObject()
    if Meteor.user()?
      Meteor.users.update({_id: Meteor.userId()},
        $set: {
          'profile.name': user.name,
          'profile.description': user.description
        }
      )
      return
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

Template.user_form.helpers
  'submitValue': -> if Meteor.user() then 'Submit' else 'Register'
