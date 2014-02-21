
assert = require('assert')

suite 'Events', ->
  test 'can be created', (done, server, client) ->
    server.eval ->
      Accounts.createUser
        email: 'a@a.com'
        password: '123456'
        profile:
          name: 'John Smith'

      Events.find().observe
        added: (event) -> emit 'event', event

    server.once 'event', (event) ->
      assert.equal event.title, 'hello title'
      done()

    client.eval ->
      event = {}
      event.title = 'hello title'
      event.description = ''
      event.from = new Date()
      event.to = new Date()
      year = event.from.getFullYear()
      event.from.setFullYear(year + 1)
      event.to.setFullYear(year + 2)
      Meteor.loginWithPassword 'a@a.com', '123456', ->
        Meteor.call 'create_event', event, (error, id) ->
          null
