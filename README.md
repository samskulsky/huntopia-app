# Huntopia

Huntopia is a real-life scavenger hunt game that allows players to claim zones, earn points, and use power-ups to gain an advantage. The app utilizes Google Analytics, Firebase, Maps, location tracking, and the phone's camera for a dynamic and interactive experience.

## Features

- **Live Scavenger Hunts**: Real-time gameplay with zone claiming and scoring.
- **Power-ups**: Players can buy power-ups like 2x score multipliers and the ability to disable other teams.
- **Google Maps Integration**: View the game zones in real-time.
- **Location Tracking**: Ensures that players are in the right place when claiming zones.
- **Firebase Integration**: User authentication, push notifications, and data management.
- **Google Analytics**: Track user activity and game analytics.

## Tech Stack

- **Framework**: Flutter
- **Backend**: Firebase, Google Maps API, Google Analytics
- **Push Notifications**: Firebase Cloud Messaging
- **Location Services**: GPS-based location tracking for real-time gameplay
- **Camera Access**: Device's camera for in-game challenges

## Getting Started

To get a copy of the project up and running, follow these steps:

### Prerequisites

- [Flutter](https://flutter.dev/) installed
- [Firebase](https://firebase.google.com/) project set up

### Installation

1. Clone the repo:

    ```bash
    git clone https://github.com/samskulsky/huntopia-app.git
    cd huntopia-app
    ```

2. Install dependencies:

    ```bash
    flutter pub get
    ```

3. Set up Firebase:

    - Add your Firebase credentials by placing `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the appropriate directories.

4. Run the app on a connected device or emulator:

    ```bash
    flutter run
    ```

## Usage

- Start a new scavenger hunt or join an existing one.
- Track your progress and use the map to claim zones.
- Use power-ups strategically to outplay other teams.
- Keep an eye on notifications for updates and tips during the game.
