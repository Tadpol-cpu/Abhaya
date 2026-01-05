Abhaya - Women's Safety Application
Abhaya is a mobile safety platform built with Flutter and Firebase. It provides a proactive safety model for women gig workers by utilizing real-time data monitoring and automated emergency alerts.

Project Overview
The application focuses on minimizing reaction time during emergencies through the following system flow:

Frontend: Built with Flutter to provide a seamless, native experience on both Android and iOS.

Authentication: Managed via Firebase Auth for secure user login and verification.

Real-time Database: Cloud Firestore stores trip data, user profiles, and emergency contacts, ensuring instant synchronization across devices.

SOS Notifications: Uses Firebase Cloud Messaging (FCM) to push instant alerts to the user's safety network.

Project Structure
lib/: Contains the Dart source code (UI screens, models, and business logic).

assets/: Static files such as images and icons.

android/ & ios/: Platform-specific configurations for Firebase integration.
