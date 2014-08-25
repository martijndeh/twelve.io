var bleno = require('bleno');
var noble = require('noble');

var Q = require('q');

var upvotes = [];
var downvotes = [];

var sender = 'E2C56DB5DFFB48D2B060D0F5A71096E0';
var receiver = 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E1';

var senderLowercase = 'e2c56db5dffb48d2b060d0f5a71096e0';
var receiverLowercase = 'e2c56db5dffb48d2b060d0f5a71096e1'; //iPhones

function startAdvertising() {
	var defer = Q.defer();

	console.log('up votes ' + upvotes.length + ' down votes ' + downvotes.length);

	bleno.startAdvertisingIBeacon(sender, upvotes.length, downvotes.length, -59, defer.makeNodeResolver());

	return defer.promise;
}

function stopAdvertising() {
	var defer = Q.defer();

	bleno.stopAdvertising(defer.makeNodeResolver());

	return defer.promise;
}

startAdvertising();

noble.on('stateChange', function(state) {
	if(state == 'poweredOn') {
		noble.startScanning([], true);
	}
});

noble.on('discover', function(beacon) {
	if(beacon && beacon.advertisement && beacon.advertisement.manufacturerData && beacon.advertisement.manufacturerData.length > 22) {
		var uuid = beacon.advertisement.manufacturerData.slice(4, 20).toString('hex');

		// We use this as the user's id.
		// TODO: Verify if this user ID is correct.
		var major = beacon.advertisement.manufacturerData.readUInt16BE(20);

		// And the type of vote: 1 = up, 0 = down.
		var minor = beacon.advertisement.manufacturerData.readUInt16BE(22);

		if(uuid == receiverLowercase) {
			// TODO: Use major-minor combination to as index to text messages in a list.

			if(downvotes.indexOf(major) < 0 && upvotes.indexOf(major) < 0) {
				if(minor === 0) {
					// down vote
					downvotes.push(major);
					console.log('received vote from ' + major + ' ' + minor);

					stopAdvertising()
						.then(function() {
							startAdvertising();
						});
				}
				else if(minor == 1) {
					// up vote
					upvotes.push(major);
					console.log('received vote from ' + major + ' ' + minor);

					stopAdvertising()
						.then(function() {
							startAdvertising();
						});
				}
			}
		}
	}
});
