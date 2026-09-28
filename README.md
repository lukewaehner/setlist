# Workout Tracker (iOS)

A UIKit iOS app for building workout templates, logging live workouts, reviewing
history with photos, sharing to a social feed, and viewing training analytics.
Built as a team final project (Andrew Kenny, Waverly Hassman, Luke Waehner),
backed by Firebase Auth, Firestore, and Storage.

## Features

- Email/password registration and login (Firebase Auth)
- Workout templates with an exercise picker
- Active workout tracking with sets, reps, and weight
- Workout history with photo attachments (Firebase Storage)
- Social workout feed
- Analytics dashboard with summary stat cards

## Running locally

1. Open `Final Project.xcodeproj` in Xcode (Swift Package Manager fetches the
   Firebase SDK automatically).
2. Create a Firebase project with Auth (email/password), Firestore, and Storage
   enabled, register an iOS app, and download its `GoogleService-Info.plist`.
3. Place that file at `Final Project/GoogleService-Info.plist` (it is
   git-ignored and not included in this repo).
4. Build and run on an iOS simulator.

## Tests

Run the default Xcode test targets with `Cmd+U` (`Final ProjectTests`,
`Final ProjectUITests`). They are the Xcode template tests only.

## Structure

```
Final Project/
  Configs/      Models (Workout, WorkoutPost, User) and Firebase managers
  Components/   Reusable views (workout cards, dividers, progress spinner)
  Screens/      One folder per screen: controller + Views/
```
