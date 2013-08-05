Template.hello.greeting = -> "Welcome to pennvents."

Template.hello.events
  'click input' : ->
      console.log("You pressed the button")
