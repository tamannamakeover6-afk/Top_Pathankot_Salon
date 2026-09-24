# Tamanna

Premium **at-home beauty services** website built with Flutter Web, GetX, Cloud Firestore, Firebase Auth, and Cloudinary.

The previous mobile salon-listing flow is paused. This project is now a responsive commercial website plus a focused admin dashboard.

## Run

```bash
flutter pub get
flutter run -d chrome
```

## GitHub Pages (live site)

The built website is in the `docs/` folder.

1. Open the repo on GitHub → **Settings** → **Pages**
2. Under **Build and deployment**:
   - Source: **Deploy from a branch**
   - Branch: **main**
   - Folder: **/docs**
3. Save, wait 1–2 minutes
4. Open: **https://tamannamakeover6-afk.github.io/Top_Pathankot_Salon/**

Do **not** use the repo root as Pages source — that only shows the README.

### Rebuild after code changes

```bash
flutter build web --release --base-href "/Top_Pathankot_Salon/"
rm -rf docs && mkdir docs && cp -R build/web/. docs/ && touch docs/.nojekyll && cp docs/index.html docs/404.html
git add docs && git commit -m "Update live site build" && git push
```

There is also a GitHub Action (`.github/workflows/deploy-pages.yml`) that can deploy automatically after you enable **Settings → Pages → Source: GitHub Actions**.

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

`users`, `categories`, `services`, `packages`, `offers`, `reviews`, `bookings`, `users/{id}/favorites`

Deploy rules/indexes from `firestore.rules` and `firestore.indexes.json`.
