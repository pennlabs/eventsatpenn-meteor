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
* On Mac, `$ mrt`
* On Linux, `$ sudo mrt` (mrt runs into weird privileges issues on Linux)

Deploying
---------

This website was developed in Meteor, a realtime communication Javascript
framework, and is hosted on their servers for ease of deployment. To deploy,
just run:

```shell
$ mrt deploy eventsatpenn.com
```

Testing
-------

To run tests, first set up [laika](http://arunoda.github.io/laika/). Then run
`make test`.
