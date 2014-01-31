this.Events = new Meteor.Collection("events")

# Note: 422 refers to HTTP 422, unprocessable entity

ERROR_EVENT_DATES_INCONSISTENT = new Meteor.Error(422,
  "Event end time cannot be before its start time.")

MIN_EVENT_DURATION_IN_MILLESCONDS = 5 * 60 * 1000

ERROR_EVENT_TOO_SHORT = new Meteor.Error(422,
  "Event duration cannot be less than five minutes.")

ERROR_EVENT_IN_PAST = new Meteor.Error(422,
  "Event start date cannot be in past.")

ERROR_EVENT_TOO_FAR_IN_FUTURE = new Meteor.Error(422,
  "Event start date is too far in the future.")

MAX_YEARS_BETWEEN_NEW_EVENT_AND_NOW = 4

Meteor.methods
  create_event: (event) ->

    from = moment(event.from)
    to   = moment(event.to)
    now  = moment()

    if from > to
      throw ERROR_EVENT_DATES_INCONSISTENT

    if to - from < MIN_EVENT_DURATION_IN_MILLESCONDS
      throw ERROR_EVENT_TOO_SHORT

    if from < now
      throw ERROR_EVENT_IN_PAST

    if from.years() - now.years() > MAX_YEARS_BETWEEN_NEW_EVENT_AND_NOW
      throw ERROR_EVENT_TOO_FAR_IN_FUTURE

    user = Meteor.user()

    event.creator = user._id
    event.creator_name = user.profile.name

    event_id = Events.insert(event)

    Meteor.users.update(Meteor.userId(), {$push: {"profile.events": event_id}})
    followers = Meteor.user().profile.followers or []
    if followers.length
      Meteor.users.update(_id: {$in: followers}, {$push: {"profile.event_queue": event_id}})

    return event_id

  # pulling events, pulls all occurences of that event out,
  # so if the user created the event or follows someone who created it,
  # it will get pulled from his/her event_queue
  #
  # when a user destroys a starred event, it still exists in the admins' events
  # to solve it, pull from everywhere IF you're the creator?
  # Meteor.users.update({}, {$pull: {"profile.events": event_id}})
  # alternatively, have a different method to un-star events as opposed to destroy
  destroy_event: (event_id) ->
    Events.remove(event_id)
    Meteor.users.update(Meteor.userId(), {$pull: {"profile.events": event_id}})
    followers = Meteor.user().profile.followers or []
    if followers.length
      Meteor.users.update(_id: {$in: followers}, {$pull: {"profile.event_queue": event_id}})

  star_event: (event_id) ->
    Events.update(event_id, {$set: {starred: {by: Meteor.user().profile.name, by_id: Meteor.userId()}}})

  unstar_event: (event_id) ->
    Events.update(event_id, {$unset: {starred: 1}})
