eventsatpenn
============

events@penn is a website for student organizations to post listing for events
they are holding, and for students to discover events happening on campus that
interest them.

events@penn is a partnership with the Daily Pennsylvanian, and will be a joint
project of both organizations.


Developing
----------

To run

    $ meteor

Deploying
---------

This website was developed in Meteor, a realtime communication Javascript
framework, and is hosted on our local [dokku](http://dokku.viewdocs.io/dokku/)
instance. To deploy, first add your ssh key to the dokku server, and add dokku
to your git remotes on the local code repository:

```shell
$ git remote add dokku dokku@apps.pennlabs.org:eventsatpenn
```

Then, to actually deploy, simply run:

```shell
$ git push dokku master
```

Make sure to deploy only once changes have been reviewed through a pull request.

Testing
-------

To run tests, first set up [laika](http://arunoda.github.io/laika/). Then run
`make test`.
