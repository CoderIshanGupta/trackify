# Trackify 🚀
> A full-stack lifestyle tracking app — expenses, workouts, mood-based activity suggestions

---

## Project Structure

```
Trackify/
├── server/          # Node.js + Express + MongoDB API
├── app/             # Flutter mobile app
└── admin_web/       # React admin dashboard (admin-only)
```

---

## Quick Start

### 1. Firebase Setup (Required)
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create a project → Enable **Google Sign-In** under Authentication
3. Download the **Service Account JSON** → save as `server/firebase-service-account.json`
4. Copy the **Web App config** → paste into `admin_web/src/firebase.js`
5. Download `google-services.json` → place in `app/android/app/`

---

### 2. Backend
```bash
cd server
cp .env.example .env         # Edit MONGO_URI and FIREBASE_SERVICE_ACCOUNT_PATH
npm install
npm run dev                  # Runs on http://localhost:5000
```

**Endpoints:**
| Method | Path | Auth |
|--------|------|------|
| POST | `/api/auth/google` | Public |
| GET/POST/PUT/DELETE | `/api/expenses` | User |
| GET/POST/PUT/DELETE | `/api/workouts` | User |
| POST | `/api/mood` | User |
| GET | `/api/mood/history` | User |
| GET | `/api/admin/users` | Admin |
| GET | `/api/admin/users/:uid` | Admin |
| PATCH | `/api/admin/users/:uid/role` | Admin |
| GET | `/api/admin/stats` | Admin |

---

### 3. Flutter App
```bash
cd app
flutter pub get
# Add google-services.json to android/app/
flutter run
```

**Change the API URL in** `lib/core/constants.dart`:
- Android emulator: `http://10.0.2.2:5000/api`
- iOS simulator: `http://localhost:5000/api`
- Physical device: `http://YOUR_LOCAL_IP:5000/api`

---

### 4. Admin Web Dashboard
```bash
cd admin_web
npm install
npm run dev                  # Runs on http://localhost:3000
```

> **Admin access:** Only Google accounts with `role: "admin"` in MongoDB can log in.
> To promote a user: use the Dashboard → Promote button, or directly update MongoDB.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3.x (Dart) |
| State | Riverpod |
| HTTP | Dio (auto Firebase token injection) |
| Auth | Firebase Auth + Google Sign-In |
| Backend | Node.js + Express |
| Database | MongoDB (Mongoose) |
| Token Verification | Firebase Admin SDK |
| Admin Web | React + Vite |

---

## Creating Your First Admin

```javascript
// In MongoDB shell or Compass
db.users.updateOne(
  { email: "your@email.com" },
  { $set: { role: "admin" } }
)
```

---

## Mood → Activities (Server-Side)

Moods: `Happy | Sad | Anxious | Angry | Tired | Excited | Calm | Bored`

Each mood returns 3 curated activity suggestions from the server. See `server/utils/moodEngine.js`.
