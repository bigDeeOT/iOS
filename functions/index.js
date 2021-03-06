const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();


exports.newRideRequest = functions.database.ref('Requests/{RequestID}').onWrite((change, context) => {
	let newRide = change.after.val();
	if (change.before.exists()) {return;}
	let msg = `${newRide.Text}`;
	return loadUsers().then(users => {
	        let tokens = [];
	        for (let user of users) {
				if (user.Class == "Driver" || user.Class == "Moderator" || user.Class == "Admin") {
					if (!("Notify" in user)) {continue;}
					if (user.Notify == "False") {continue;}
					if (!("LoggedIn" in userInfo)) {return;}
					if (userInfo.LoggedIn == "False") {return;}
	            	tokens.push(user.pushToken);
				}
	        }
	        let payload = {
	            notification: {
	                title: 'New Ride Request',
	                body: msg,
	                sound: 'default',
	                badge: '1'
	            }
	        };
	        return admin.messaging().sendToDevice(tokens, payload);
	    });
});

function loadUsers() {
	let dbRef = admin.database().ref('Users');
	let defer = new Promise((resolve, reject) => {
		dbRef.once('value', (snap, context) => {
			let data = snap.val();
			let users = [];
			for (var property in data) {
				users.push(data[property]);
			}
			resolve(users);
	    }, (err) => {
	        reject(err);
	    });
	});
	return defer;
}

/***** Offer Notification ****/

exports.newRideOffer = functions.database.ref('Offers/{OfferID}').onWrite((data, context) => {
	let newOffer = data.after.val();
	let driverID = newOffer.Driver;
	let rideRequestID = newOffer['Ride Request'];
	let offerComment = newOffer.Comment;
	let dbRefDriver = admin.database().ref(`Users/${driverID}`);
	dbRefDriver.once('value', (snapDriver, context) => {
		let driverData = snapDriver.val();
		let driverName = driverData.Name;
		let dbRefRideRequest = admin.database().ref(`Requests/${rideRequestID}`);
		dbRefRideRequest.once('value', (snapRideRequest, context) => {
			let riderData = snapRideRequest.val();
			let riderID = riderData.Rider;
			let dbRefRider = admin.database().ref(`Users/${riderID}`);
			dbRefRider.once('value', (snapRider, context) => {
				let riderData = snapRider.val();
				let riderToken = riderData.pushToken;
				if (!("Notify" in riderData)) {return;}
				if (riderData.Notify == "False") {return;}
				if (!("LoggedIn" in userInfo)) {return;}
				if (userInfo.LoggedIn == "False") {return;}
		        let payload = {
		            notification: {
		                title: `${driverName} offered a ride!`,
		                body: offerComment,
		                sound: 'default',
		                badge: '1'
		            }
		        };
				return admin.messaging().sendToDevice(riderToken, payload);
			});
		});
	});
});

exports.newChatMessage = functions.database.ref('Conversation Meta Data/{convoID}').onWrite((data, context) => {
	let metaData = data.after.val();
	var userID = ""
	var senderID = ""
	for (var key in metaData) {
		if (metaData[key] == "Unread") {
			userID = key;
		}
		if (metaData[key] == "Read") {
			senderID = key;
		}
	}
	if (userID == "") {return;}
	let msg = metaData['Last Message'];
	admin.database().ref(`Users/${senderID}`).once('value', (snapShotSender, context) => {
		let senderInfo = snapShotSender.val();
		let senderName = senderInfo.Name;
		admin.database().ref(`Users/${userID}`).once('value', (snapShot, context) => {
			let userInfo = snapShot.val();
			if (!("Notify" in userInfo)) {return;}
			if (userInfo.Notify == "False") {return;}
			if (!("LoggedIn" in userInfo)) {return;}
			if (userInfo.LoggedIn == "False") {return;}
			let riderToken = userInfo.pushToken
			let payload = {
				notification: {
					title: `${senderName}`,
					body: msg,
					sound: 'default',
					badge: '1'
				},
				data: {
					isMessage: 'true'
				}
			};
			return admin.messaging().sendToDevice(riderToken, payload);
		});
	});
});




// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions