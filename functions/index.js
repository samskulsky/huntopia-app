const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const OpenAI = require('openai');
const { v4: uuidv4 } = require('uuid');
const axios = require('axios');

const openai = new OpenAI({
  apiKey: functions.config().openai.key,
});

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

async function generateGameMetadata(description) {
  const response = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [{
      role: "user",
      content: `Create a catchy game name and expanded description for a scavenger hunt game with this user prompt: "${description}". Return as JSON with "name" and "description" fields. The description should be exciting and inviting, about 1-2 sentences long. Not too edgy, but not too boring.`
    }],
    response_format: { type: "json_object" },
    temperature: 0.7,
  });

  const content = JSON.parse(response.choices[0].message.content);
  return {
    name: content.name,
    description: content.description
  };
}

exports.generateAIGame = functions
  .runWith({
    timeoutSeconds: 540,
    memory: '512MB'
  })
  .firestore
  .document('aiGameRequests/{requestId}')
  .onCreate(async (snap, context) => {
    const requestData = snap.data();
    const requestRef = snap.ref;

    try {
      await requestRef.update({
        status: 'processing',
        message: 'Starting generation...',
        progress: 0
      });

      const metadata = await generateGameMetadata(requestData.description);

      await requestRef.update({
        message: 'Generating zones...',
        progress: 10
      });

      const allResponses = await generateMultipleZoneMessages(
        requestData.description,
        requestData.totalZones,
        [],
        [],
        requestRef
      );

      const gameData = await combineZones(allResponses, requestRef);

      const gameTemplate = {
        templateId: uuidv4(),
        creatorUid: requestData.userId,
        creatorName: 'AI Game Creator',
        gameType: 'claimthezone',
        createdAt: admin.firestore.Timestamp.now(),
        lastUpdated: admin.firestore.Timestamp.now(),
        zones: gameData.zones,
        gameName: metadata.name,
        gameDescription: metadata.description,
        center: new admin.firestore.GeoPoint(
          gameData.zones[0].location.latitude,
          gameData.zones[0].location.longitude
        ),
        coinShopItems: getCoinShopItems(),
        defaultGameSettings: {
          gameDuration: 3600,
          teamSize: 4,
          maxTeams: 10,
          publicGame: true,
          allowJoinAfterStart: true,
          allowSpectators: true,
          showLeaderboard: true,
          showPlayerLocations: true,
          showZoneLocations: true,
          showZoneStatus: true,
          showTeamScores: true,
          showIndividualScores: true,
        }
      };

      // Save the game template
      await admin.firestore()
        .collection('gameTemplates')
        .doc(gameTemplate.templateId)
        .set(gameTemplate);

      // Update request status
      await requestRef.update({
        status: 'completed',
        message: 'Game generated successfully!',
        gameTemplateId: gameTemplate.templateId,
      });

      // Send notification to user
      const message = {
        data: {
          title: 'Game Generated!',
          body: 'Your AI-generated game is ready to play!',
        },
        topic: `user-${requestData.userId}`,
      };

      await admin.messaging().send(message);

    } catch (error) {
      console.error('Error generating game:', error);
      await requestRef.update({
        status: 'error',
        message: `Error: ${error.message}`,
      });
    }
  });

function getPrompt(description, numZones, existingZoneNames, existingGeoPoints) {
  const existingZonesStr = existingZoneNames.length ? existingZoneNames.join(", ") : "None";
  const existingGeoPointsStr = existingGeoPoints.length ? existingGeoPoints.join(", ") : "None";

  return `
In ClaimRush, teams compete to earn points by claiming "zones" within a time limit. They claim a zone by completing a task there, after which the zone is locked. Each zone has a specific task (question or selfie) and location.
The game is played via a Flutter/Firebase app, using the following JSON structure:
{
  "gameName": "Sample Game",
  "gameDescription": "A sample game description.",
  "center": {
    "latitude": 35.0000,
    "longitude": 136.0000
  },
  "zones": [
    {
      "zoneId": "123e4567-e89b-12d3-a456-426614174000",
      "zoneName": "Famous Building",
      "location": {
        "latitude": 35.0000,
        "longitude": 136.0000
      },
      "radius": 25,
      "clue": "What is the color of the building?",
      "answer": "Blue",
      "taskType": "question",
      "points": 10,
      "coins": 5,
      "originalPoints": 10
    }
  ]
}
The game ALREADY has the following zone names: [${existingZonesStr}].
DO NOT make ANY zones with the same name or location as the existing zones -- NO OVERLAPS.
Always use SPECIFIC LOCATIONS, ex. like "Space Mountain" instead of "Roller Coaster" (these are just examples). Ensure the names are accurate.
The names are searched in GOOGLE MAPS to get the exact coordinates, so ONLY locations that would be found.
Try to SPREAD THE ZONES OUT across the area, as it makes the game take longer and be more fun.
Zones that are harder to get to, have more challenging tasks, or have fewer nearby zones should have higher points (25-50). Zones that are in a cluster, are easier to get to, and have easy tasks should have lower points (5 - 25).
Based on this structure, generate a JSON object for a game template with ${numZones} zones. Ensure zones have accurate latitude and longitude coordinates, and the description is: ${description}. Only return the JSON object, nothing else. If you cannot generate it, respond with "error".
DO RELEVANT AND INTERESTING CHALLENGES.`;
}

async function generateMultipleZoneMessages(description, totalZones, existingZoneNames, existingGeoPoints, requestRef) {
  const batchSize = 5;
  const allResponses = [];
  let zonesRemaining = totalZones;

  while (zonesRemaining > 0) {
    const numZonesToGenerate = Math.min(batchSize, zonesRemaining);
    const prompt = getPrompt(description, numZonesToGenerate, existingZoneNames, existingGeoPoints);

    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{
        role: "user",
        content: prompt,
      }],
      response_format: { type: "json_object" },
      temperature: 0.7,
    });

    if (!response.choices[0]?.message?.content) {
      throw new Error('No valid content returned in GPT response');
    }

    const content = response.choices[0].message.content.trim();
    if (content.toLowerCase() === "error") {
      throw new Error('GPT returned an error response.');
    }

    allResponses.push(response);

    const gameMap = JSON.parse(content);
    const newZoneNames = gameMap.zones.map(zone => zone.zoneName);
    const newGeoPoints = gameMap.zones.map(zone =>
      `${zone.location.latitude}:${zone.location.longitude}`
    );

    existingZoneNames.push(...newZoneNames);
    existingGeoPoints.push(...newGeoPoints);

    zonesRemaining -= numZonesToGenerate;

    const progress = ((totalZones - zonesRemaining) / totalZones * 100).toFixed(0);
    await requestRef.update({
      message: `Generating zones (${progress}%)...`,
    });
  }

  return allResponses;
}

async function geocodeAddresses(addresses, biasLongitude, biasLatitude, radiusMeters) {
  const GEOAPIFY_API_KEY = functions.config().geoapify.key;
  const url = `https://api.geoapify.com/v1/batch/geocode/search?apiKey=${GEOAPIFY_API_KEY}&bias=proximity:${biasLongitude},${biasLatitude}&filter=circle:${biasLongitude},${biasLatitude},${radiusMeters}`;

  const response = await axios.post(url, addresses, {
    headers: { 'Content-Type': 'application/json' }
  });

  if (response.status !== 202) {
    throw new Error(`Failed to create batch job: ${response.status} ${response.statusText}`);
  }

  const { id: jobId, url: jobUrl } = response.data;
  let isCompleted = false;
  let attempts = 0;
  const maxAttempts = 100;

  while (!isCompleted && attempts < maxAttempts) {
    await new Promise(resolve => setTimeout(resolve, 5000));
    attempts++;

    const jobResponse = await axios.get(jobUrl);

    if (jobResponse.status === 200) {
      const results = jobResponse.data;
      const geocodedLocations = {};

      for (const result of results) {
        const queryText = result.query.text;
        if (result.lon && result.lat) {
          const lon = typeof result.lon === 'string' ? parseFloat(result.lon) : result.lon;
          const lat = typeof result.lat === 'string' ? parseFloat(result.lat) : result.lat;
          geocodedLocations[queryText] = new admin.firestore.GeoPoint(lat, lon);
        }
      }

      return geocodedLocations;
    }
  }

  throw new Error('Batch job did not complete in time');
}

async function combineZones(allResponses, requestRef) {
  const combinedZones = [];
  const zoneNames = new Set();
  const geoPoints = new Set();
  let centerPoint = null;

  for (const response of allResponses) {
    try {
      const content = response.choices[0].message.content.trim();
      const gameMap = JSON.parse(content);

      if (!centerPoint && gameMap.center) {
        centerPoint = {
          latitude: gameMap.center.latitude,
          longitude: gameMap.center.longitude,
        };
      }

      for (const zone of gameMap.zones) {
        const geoPointKey = `${zone.location.latitude}:${zone.location.longitude}`;

        if (!zoneNames.has(zone.zoneName) && !geoPoints.has(geoPointKey)) {
          combinedZones.push({
            zoneId: uuidv4(),
            zoneName: zone.zoneName,
            location: new admin.firestore.GeoPoint(
              zone.location.latitude,
              zone.location.longitude
            ),
            radius: Math.min(zone.radius, 50),
            clue: zone.clue,
            answer: zone.answer || '',
            photoURL: zone.photoURL || '',
            qrCode: zone.qrCode || '',
            taskType: zone.taskType,
            points: zone.points,
            coins: zone.coins,
            originalPoints: zone.originalPoints,
          });
          zoneNames.add(zone.zoneName);
          geoPoints.add(geoPointKey);
        }
      }
    } catch (error) {
      console.error('Error processing response:', error);
    }
  }

  if (!centerPoint) {
    throw new Error('Failed to extract center from GPT responses.');
  }

  await requestRef.update({ message: "Improving zone coordinates..." });

  const addresses = combinedZones.map(zone => zone.zoneName);
  const geocodedLocations = await geocodeAddresses(
    addresses,
    centerPoint.longitude,
    centerPoint.latitude,
    8047
  );

  for (const zone of combinedZones) {
    if (geocodedLocations[zone.zoneName]) {
      zone.location = geocodedLocations[zone.zoneName];
    }
  }

  return {
    zones: combinedZones,
    coinShopItems: getCoinShopItems(),
  };
}

function getCoinShopItems() {
  return [
    {
      itemId: "1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p",
      itemName: "Point Boost 1.5x",
      itemDescription: "Boosts points earned by 1.5x for 15 minutes.",
      itemPrice: 20,
      pointsPerCoin: 1,
      itemType: "booster",
      multiplier: 1.5,
      duration: 15
    },
    {
      itemId: "2b3c4d5e-6f7g-8h9i-0j1k-2l3m4n5o6p7q",
      itemName: "Point Boost 2x",
      itemDescription: "Boosts points earned by 2x for 15 minutes.",
      itemPrice: 30,
      pointsPerCoin: 1,
      itemType: "booster",
      multiplier: 2,
      duration: 15
    },
    {
      itemId: "3c4d5e6f-7g8h-9i0j-1k2l-3m4n5o6p7q8r",
      itemName: "15 Min Sabotage",
      itemDescription: "Disables opponents for 15 minutes.",
      itemPrice: 25,
      pointsPerCoin: 1,
      itemType: "disabler",
      multiplier: 1,
      duration: 15
    },
    {
      itemId: "4d5e6f7g-8h9i-0j1k-2l3m-4n5o6p7q8r9s",
      itemName: "30 Min Sabotage",
      itemDescription: "Disables opponents for 30 minutes.",
      itemPrice: 45,
      pointsPerCoin: 1,
      itemType: "disabler",
      multiplier: 1,
      duration: 30
    },
    {
      itemId: "5e6f7g8h-9i0j-1k2l-3m4n-5o6p7q8r9s0t",
      itemName: "Coin ATM",
      itemDescription: "Earns 2 points for each coin spent.",
      itemPrice: 5,
      pointsPerCoin: 2,
      itemType: "coin",
      multiplier: 1,
      duration: 0
    },
    {
      itemId: "6f7g8h9i-0j1k-2l3m-4n5o-6p7q8r9s0t1u",
      itemName: "Task Skip",
      itemDescription: "Skips a task.",
      itemPrice: 10,
      pointsPerCoin: 1,
      itemType: "skip",
      multiplier: 1,
      duration: 0
    }
  ];
}

