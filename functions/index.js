const functions = require('firebase-functions');
let admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);


exports.newRideRequest = functions.database.ref('Requests/{RequestID}').onWrite(event => {
	let newRide = event.data.val();
	if (event.data.previous.exists()) {return;}
	let msg = `${newRide.Text}`;
	return loadUsers().then(users => {
	        let tokens = [];
	        for (let user of users) {
				if (user.Class == "Driver" || user.Class == "Moderator" || user.Class == "Admin") {
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
		dbRef.once('value', (snap) => {
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

exports.newRideOffer = functions.database.ref('Offers/{OfferID}').onWrite(event => {
	let newOffer = event.data.val();
	let driverID = newOffer.Driver;
	let rideRequestID = newOffer['Ride Request'];
	let offerComment = newOffer.Comment;
	let dbRefDriver = admin.database().ref(`Users/${driverID}`);
	dbRefDriver.once('value', (snapDriver) => {
		let driverData = snapDriver.val();
		let driverName = driverData.Name;
		let dbRefRideRequest = admin.database().ref(`Requests/${rideRequestID}`);
		dbRefRideRequest.once('value', (snapRideRequest) => {
			let riderData = snapRideRequest.val();
			let riderID = riderData.Rider;
			let dbRefRider = admin.database().ref(`Users/${riderID}`);
			dbRefRider.once('value', (snapRider) => {
				let riderData = snapRider.val();
				let riderToken = riderData.pushToken;
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




// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions