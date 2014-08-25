twelve.io
=========

iBeacon Experience Days 2014 voting system prototype.

In `/server` you'll find an example Node app which emits a beacon with the number of up- and downvotes. To run:

```
$ npm install
$ node index.js
```

In `/app` you'll find a small iOS app which listens to the server's beacon and shows the up- and downvotes. It also has up- and downvotes buttons: when voting, a beacon is advertised on the iOS device for 5 seconds. The server picks this up and registers the vote.
