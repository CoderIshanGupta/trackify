# 📱 Trackify – Smart All-in-One Personal Tracking App

Trackify is a modern, AI-enhanced personal tracking app built with **Flutter**. It creates a beautifully integrated ecosystem to track everything that matters to your day-to-day growth: mood, mental wellness, tasks, focus, habits, expenses, productivity, and more.

The app utilizes **Firebase** for real-time syncing and storage, and leverages **OpenAI APIs** and **ML Kit** for sentiment analysis, OCR, intelligent insights, and personalized recommendations.

---

## ✨ Key Features

* 🧠 Mood & Mental Wellness Tracker
* ✅ Task + Focus Planners.
* 🔄 Habit & Health Tracker
* 💰 Expense & Budget Tracker
* 📊 Study & Productivity Analytics

---

## 🛠️ Tech Stack

*   **Framework:** Flutter 3+ (Dart)
*   **Backend:** Firebase (Firestore, Realtime DB, Cloud Functions, Auth)
*   **AI & ML:**
    *   OpenAI API (Sentiment analysis, Chat, Recommendations)
    *   Google ML Kit (Text Recognition/OCR)
*   **Integrations:** Calendar APIs, Google Fit / Apple Health (Optional)

---

## 🏗 Project Structure

```text
lib/
 ├── modules/
 │    ├── mood/            # Mood logging, charts, AI chat
 │    ├── tasks/           # Kanban board, Pomodoro, Calendar
 │    ├── habits/          # Streak logic, health integrations
 │    ├── expenses/        # Budgeting, OCR scanner
 │    └── analytics/       # Cross-module insights, Life Score
 ├── services/
 │    ├── firebase/        # Firestore, Realtime DB, Cloud Functions
 │    ├── ai/              # OpenAI wrapper, ML Kit logic
 │    ├── auth_service.dart
 ├── widgets/              # Reusable UI components
 └── main.dart             # App entry point

```
---
### Setup Instructions

```bash
git clone https://github.com/CoderIshanGupta/trackify.git
cd trackify
flutter pub get
flutter run
````
---

## 🧪 Running Tests

```bash
flutter test
```

Unit tests are primarily found under `test/models/` and widget tests under `test/widgets/`.

---

## 🤝 Contribution Guide

We love ICs and contributors! Please follow these steps:

1. Fork and clone the repo.
2. Create a new branch: `git checkout -b feature/my-feature`
3. Commit your changes with clear messages.
4. Submit a PR and link to your issue.

### Folder Naming Conventions

* All screens: `snake_case_view.dart`
* Models and Providers: `feature_model.dart`, `feature_provider.dart`
* Widgets: grouped under `widgets/` in categorized folders

---

## 👥 Team & Credits

Made with ❤️ by the CN KIIT team and open-source contributors.

---

## 📄 License

[MIT License](LICENSE)
