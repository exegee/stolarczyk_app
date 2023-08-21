const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");

admin.initializeApp();

// Cloud Firestore triggers ref: https://firebase.google.com/docs/functions/firestore-events
exports.myFunction = functions.firestore
  .document("chat/{messageId}")
  .onCreate((snapshot, context) => {
    // Return this function's promise, so this ensures the firebase function
    // will keep running, until the notification is scheduled.
    return admin.messaging().sendToTopic("chat", {
      // Sending a notification message.
      notification: {
        title: snapshot.data()["username"],
        body: snapshot.data()["text"],
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
        sound : 'default',
        
      },
    });
  });

  exports.onTopicModified = onDocumentUpdated("topics/{topicId}", (event) => {
    const snapshot = event.data; 
    if(!snapshot){
        console.log('No data associated with the event');
        return;
    }

    //const data = snapshot.data();
    // console.log(event.data.after.uid);
    const docId = snapshot.after.id;
    const topic = snapshot.after.data();
    console.log(event.source);
    //console.log(snapshot.after.id);
    admin.messaging().sendToTopic(docId, {
        notification: {
            title: `Zaktualizowano temat ${topic['name']}`, 
            body: topic['shortDescription'],
            sound : 'default'
        },
        data: {
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            screen: '/topic-detail',
            data: docId
        },
        
    });

  });