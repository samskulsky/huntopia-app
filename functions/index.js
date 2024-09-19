const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendLogNotification = functions.firestore
  .document("games/{gameId}")
  .onUpdate(async (change, context) => {
    const beforeLogMessages = change.before.data().logMessages;
    const afterLogMessages = change.after.data().logMessages;

    if (afterLogMessages.length > beforeLogMessages.length) {
      const newLogMessage = afterLogMessages[afterLogMessages.length - 1];
      const imageUrl = newLogMessage.imageUrl || "";
      if (imageUrl !== "") {
        const message = {
          data: {
            title: newLogMessage.displayName,
            body: newLogMessage.message,
            imageUrl: imageUrl,
          },
          android: {
            notification: {
              imageUrl: imageUrl,
            },
          },
          apns: {
            payload: {
              aps: {
                "mutable-content": 1,
              },
            },
            fcm_options: {
              image: imageUrl,
            },
          },
          webpush: {
            headers: {
              image: imageUrl,
            },
          },
          topic: `game-${context.params.gameId}`,
        };

        admin
          .messaging()
          .send(message)
          .then((response) => {
            // Response is a message ID string.
            console.log("Successfully sent message:", response);
          })
          .catch((error) => {
            console.log("Error sending message:", error);
          });
      } else {
        const message = {
          data: {
            title: newLogMessage.displayName,
            body: newLogMessage.message,
          },
          topic: `game-${context.params.gameId}`,
        };
        admin
          .messaging()
          .send(message)
          .then((response) => {
            // Response is a message ID string.
            console.log("Successfully sent message:", response);
          })
          .catch((error) => {
            console.log("Error sending message:", error);
          });
      }
    }
  });

