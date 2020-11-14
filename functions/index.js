const functions = require('firebase-functions');
const admin = require("firebase-admin");
admin.initializeApp();

exports.onCreateFriend = functions.firestore
    .document("/friends/{userId}/userFriends/{friendId}")
    .onCreate(async (snapshot, context) => {
        console.log("Friend Created", snapshot.id);
        const userId = context.params.userId;
        const friendId = context.params.friendId;

        // 1) Create followed users meetups ref
        const friendUserMeetupsRef = admin
            .firestore()
            .collection("meetups")
            .doc(userId)
            .collection("userMeetups");

        // 2) Create following user's timeline ref
        const timelineMeetupsRef = admin
            .firestore()
            .collection("timeline")
            .doc(friendId)
            .collection("timelineMeetups")




        // 3) Get followed users meetups
//        const querySnapshot = await friendUserMeetupsRef.get();
        // 4) Add each user meetup to following user's timeline
//        querySnapshot.forEach(doc => {
//            if (doc.exists) {
//                const meetupId = doc.id;
//                const meetupData = doc.data();
//                timelineMeetupsRef.doc(meetupId).set(meetupData);
//            }
//        });
    });

exports.onDeleteFriend = functions.firestore
    .document("/friends/{userId}/userFriends/{friendId}")
    .onDelete(async (snapshot, context) => {
        console.log("Friend Deleted", snapshot.id);

        const userId = context.params.userId;
        const friendId = context.params.friendId;

        const timelineMeetupsRef = admin
            .firestore()
            .collection("timeline")
            .doc(friendId)
            .collection("timelineMeetups")
            .where("hostId", "==", userId);

        const querySnapshot = await timelineMeetupsRef.get();
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                doc.ref.delete();
            }
        });
    });

// when a meetup is created, add meetup to timeline of each friend (of meetup owner)
exports.onCreateMeetup = functions.firestore
    .document("/meetups/{userId}/userMeetups/{meetupId}")
    .onCreate(async (snapshot, context) => {
        const meetupCreated = snapshot.data();
        const userId = context.params.userId;
        const meetupId = context.params.meetupId;

        // 1) Get all the friends of the user who made the meetup
        const userfriendsRef = admin
            .firestore()
            .collection("friends")
            .doc(userId)
            .collection("userFriends");

        const querySnapshot = await userfriendsRef.get();
        // 2) Add new meetup to each friend's timeline
        querySnapshot.forEach(doc => {
            const friendId = doc.id;
            if (meetupCreated.accept[friendId] != null) {
                admin
                    .firestore()
                    .collection("timeline")
                    .doc(friendId)
                    .collection("timelineMeetups")
                    .doc(meetupId)
                    .set(meetupCreated);
            }
        });

        await admin
            .firestore()
            .collection("timeline")
            .doc(userId)
            .collection("timelineMeetups")
            .doc(meetupId)
            .set(meetupCreated)


    });

exports.onUpdateMeetup = functions.firestore
    .document("/meetups/{userId}/userMeetups/{meetupId}")
    .onUpdate(async (change, context) => {
        const meetupUpdated = change.after.data();
        const userId = context.params.userId;
        const meetupId = context.params.meetupId;

        // 1) Get all the friends of the user who made the meetup
        const userfriendsRef = admin
            .firestore()
            .collection("friends")
            .doc(userId)
            .collection("userFriends");

        const querySnapshot = await userfriendsRef.get();
        // 2) Update each meetup in each friend's timeline
        querySnapshot.forEach(doc => {
            const friendId = doc.id;
            if (meetupUpdated.accept[friendId] != null) {
                admin
                    .firestore()
                    .collection("timeline")
                    .doc(friendId)
                    .collection("timelineMeetups")
                    .doc(meetupId)
                    .get()
                    .then(doc => {
                        if (doc.exists) {
                            doc.ref.update(meetupUpdated);
                        }
                    });
            }
        });

        admin
            .firestore()
            .collection("timeline")
            .doc(userId)
            .collection("timelineMeetups")
            .doc(meetupId)
            .get()
            .then(doc => {
                if (doc.exists) {
                    doc.ref.update(meetupUpdated);
                }
            });
    });

exports.onDeleteMeetup = functions.firestore
    .document("/meetups/{userId}/userMeetups/{meetupId}")
    .onDelete(async (snapshot, context) => {
        const meetupDeleted = snapshot.data()
        const userId = context.params.userId;
        const meetupId = context.params.meetupId;

        // 1) Get all the friends of the user who made the meetup
        const userfriendsRef = admin
            .firestore()
            .collection("friends")
            .doc(userId)
            .collection("userFriends");

        const querySnapshot = await userfriendsRef.get();
        // 2) Delete each meetup in each friend's timeline
        querySnapshot.forEach(doc => {
            const friendId = doc.id;
            if (meetupDeleted.accept[friendId] != null) {
                admin
                    .firestore()
                    .collection("timeline")
                    .doc(friendId)
                    .collection("timelineMeetups")
                    .doc(meetupId)
                    .get()
                    .then(doc => {
                        if (doc.exists) {
                            doc.ref.delete();
                        }
                    });
            }});

        admin
            .firestore()
            .collection("timeline")
            .doc(userId)
            .collection("timelineMeetups")
            .doc(meetupId)
            .get()
            .then(doc => {
                if (doc.exists) {
                    doc.ref.delete();
                }
            });
    });

exports.onCreateActivityFeedItem = functions.firestore
    .document("/feed/{userId}/feedItems/{activityFeedItem}")
    .onCreate(async (snapshot, context) => {
        console.log("Activity Feed Item Created", snapshot.data());

        // 1) Get user connected to the feed
        const userId = context.params.userId;

        const userRef = admin.firestore().doc(`users/${userId}`);
        const doc = await userRef.get();

        // 2) Once we have user, check if they have a notification token; send notification, if they have a token
        const androidNotificationToken = doc.data().androidNotificationToken;
        const createdActivityFeedItem = snapshot.data();
        if (androidNotificationToken) {
            sendNotification(androidNotificationToken, createdActivityFeedItem);
        } else {
            console.log("No token for user, cannot send notification");
        }

        function sendNotification(androidNotificationToken, activityFeedItem) {
            let body;

            // 3) switch body value based off of notification type
            switch (activityFeedItem.type) {
                case "accept":
                    body = `${activityFeedItem.displayName} accepted your meetup request`;
                    break;
                case "friend":
                    body = `${activityFeedItem.displayName} added you as a friend`;
                    break;
                case "confirm":
                    body = `${activityFeedItem.displayName} confirmed your meetup`;
                    break;
                case "decline":
                    body = `${activityFeedItem.displayName} declined your meetup request`;
                    break;
                case "invite":
                    body = `${activityFeedItem.displayName} sent you a meetup invite`;
                    break;
                case "cancel":
                    body = `${activityFeedItem.displayName} cancelled your meetup`;
                    break;
                default:
                    break;

            }

            // 4) Create message for push notification
            const message = {
                notification: {body},
                token: androidNotificationToken,
                data: {recipient: userId}
            };

            // 5) Send message with admin.messaging()
            admin
                .messaging()
                .send(message)
                .then(response => {
                    // Response is a message ID string
                    console.log("Successfully sent message", response);
                })
                .catch(error => {
                    console.log("Error sending message", error);
                });
        }
    });


exports.onCreateMessage = functions.firestore
    .document("/messages/{userId}/{receiverUid}/{Message}")
    .onCreate(async (snapshot, context) => {
        console.log("Message Received", snapshot.data());

        // 1) Get user connected to the feed
        const userId = context.params.userId;

        const userRef = admin.firestore().doc(`users/${userId}`);
        const doc = await userRef.get();

        // 2) Once we have user, check if they have a notification token; send notification, if they have a token
        const androidNotificationToken = doc.data().androidNotificationToken;
        const createdMessage = snapshot.data();
        if (androidNotificationToken) {
            sendNotification(androidNotificationToken, createdMessage);
        } else {
            console.log("No token for user, cannot send notification");
        }

        function sendNotification(androidNotificationToken, Message) {
            let body;

            // 3) switch body value based off of notification type
            if (Message.receiverUid == userId ) {
                    body = `${Message.senderName} sent you a message`;
            }


            // 4) Create message for push notification
            const message = {
                notification: {body},
                token: androidNotificationToken,
                data: {recipient: userId}
            };

            // 5) Send message with admin.messaging()
            admin
                .messaging()
                .send(message)
                .then(response => {
                    // Response is a message ID string
                    console.log("Successfully sent message", response);
                })
                .catch(error => {
                    console.log("Error sending message", error);
                });
        }
    });