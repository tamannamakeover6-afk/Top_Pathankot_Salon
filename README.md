# Tamanna

Premium **at-home beauty services** website built with Flutter Web, GetX, Cloud Firestore, Firebase Auth, and Cloudinary.

The previous mobile salon-listing flow is paused. This project is now a responsive commercial website plus a focused admin dashboard.

## Run

```bash
flutter pub get
flutter run -d chrome
```

## Build for Firebase Hosting

```bash
flutter build web --release
firebase deploy --only hosting,firestore
```

## First admin user

1. Sign up on `/signup`.
2. In Firebase Console → Firestore → `users/{uid}` set:
   - `isAdmin: true`
   - `role: "admin"`
3. Refresh and open `/admin`.

Manage catalog from Admin (categories, services, packages, offers). Data lives in Firestore.

## Cloudinary

Existing unsigned preset is reused:

- Cloud name: `juulrv7s`
- Upload preset: `tamanna_uploads`

Images are stored as `imageUrl` + `imagePublicId` in Firestore. Delivery uses `f_auto,q_auto` transformations.

## Firestore collections

`users`, `categories`, `subcategories`, `services`, `packages`, `offers`, `reviews`, `bookings`, `users/{id}/favorites`

Deploy rules/indexes from `firestore.rules` and `firestore.indexes.json`.
