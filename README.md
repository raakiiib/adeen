# Adeen • عدين 🌙

Adeen is a premium, feature-rich Flutter spiritual companion app designed to facilitate daily Islamic practices. With a focus on visual excellence, localized responsiveness, and complete offline capability, Adeen integrates prayer tracking, mosque mapping, fasting logging, and Quranic learning into a beautifully unified experience.

---

## 🌟 Key Features

### 1. Dynamic Prayer Timings & Countdown
* **Live Countdown**: A real-time header showing the current prayer, time elapsed, and next prayer countdown.
* **Offline Calculation**: Uses the Aladhan API with complete Hive database caching to calculate prayer times dynamically offline.
* **Prohibited Windows**: Displays the three prohibited/Kerahat windows (during Sunrise, Zawal/Midday, and Sunset) with allowed/forbidden status badges.
* **Special Timings**: Real-time status indicators for Tahajjud (night vigil) and Ishraq (sunrise) prayer timings.

### 2. Nearby Mosque Locator
* **Google Places Integration**: Fetches mosques in a 10km radius with customized Maps styling corresponding to your active theme preset.
* **Facility Filtering**: Filter mosques by women's sections, parking space, and multiple Jummah shifts.
* **Navigation**: Quick routing with distance calculations and navigation links.

### 3. Spiritual Hub Tracker
* **Daily Prayers Log**: Track and log daily prayer completions (Jamaat, Individual, Qaza, or Missed).
* **Qaza Backlog Tracker**: Easily maintain and resolve a backlog of missed historical prayers.
* **Fasting Tracker**: Daily Ramadan fasting logs and Sehri/Iftar countdowns.

### 4. Interactive Quranic Quiz & Tafsir Review
* **Daily Session**: Generates 7 daily trivia questions about Quranic history, prophets, and context.
* **Self-Healing Translations**: Dynamically translates questions, options, and Tafsir summaries into the user's active locale with Google Translate fallback checks.
* **Rich Tafsir Cards**: Reviews answers with a book-like container highlighting the Tafsir insights of each question.
* **Laravel Cloud Sync**: Syncs user score and logs in the background with a server endpoint.

### 5. Premium Themes & Language Localization
* **Color Schemes**: 3 curated, premium theme presets—**Emerald Green**, **Sapphire Blue**, and **Ruby Red**—in both Light and Dark modes.
* **9 Languages**: Supports English, Arabic (RTL), Bengali, Hindi, Urdu (RTL), Indonesian, Malay, Turkish, and French.

---

## 🛠 Tech Stack

* **Frontend**: [Flutter SDK](https://flutter.dev) (Dart)
* **State Management**: [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod)
* **Local Caching (NoSQL)**: [Hive DB](https://pub.dev/packages/hive)
* **Network Client**: [Dio](https://pub.dev/packages/dio) & [Http](https://pub.dev/packages/http)
* **Map Services**: [Google Maps SDK](https://pub.dev/packages/google_maps_flutter)
* **Location Services**: [Geolocator](https://pub.dev/packages/geolocator)

---

## 📦 Project Directory Structure

```text
lib/
├── core/
│   ├── database/        # Hive DB Initialization & Service
│   ├── localization/    # App Translation Delegates & JSON resources
│   ├── theme/           # AppTheme presets, palettes, & Custom Painters
│   ├── widgets/         # Shared UI components (Drawer, Layouts)
│   └── config/          # Local Configuration & Gitignored Secrets template
└── features/
    ├── dashboard/       # Prayer Timetable & Home screen features
    ├── mosque_map/      # Google Maps Mosque locator & Places API integration
    ├── profile/         # User statistics & weekly logs
    ├── quiz/            # Daily Quranic Quiz controller, database & Tafsir Review
    └── settings/        # Locale, Theme, Preset, & Calculation Method configurations
```

---

## 🔐 Getting Started & Secrets Setup

To prevent API keys from leaking into the public repository, all key bindings are extracted into local, gitignored files with safe fallbacks configured. 

Follow these steps to configure your environment:

### 1. Clone & Set Up Dart Config
1. Duplicate `lib/core/config/secrets.template.dart` and name the copy **`secrets.dart`**:
   ```bash
   cp lib/core/config/secrets.template.dart lib/core/config/secrets.dart
   ```
2. Open `lib/core/config/secrets.dart` and replace the placeholder string with your Google Places API Key.

### 2. Set Up Android Configurations
1. Open `android/local.properties` (this file is gitignored by default).
2. Append your Google Maps API key at the bottom of the file:
   ```properties
   google.maps.api.key=YOUR_GOOGLE_MAPS_API_KEY_HERE
   ```
   *The Gradle compiler will automatically inject this key into `AndroidManifest.xml` as a build placeholder during compilation.*

### 3. Set Up iOS Configurations
1. Create a file named **`secrets.xcconfig`** under `ios/Flutter/`:
   ```bash
   touch ios/Flutter/secrets.xcconfig
   ```
2. Populate the file with your iOS Maps API key:
   ```properties
   GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY_HERE
   ```
   *Xcode will import this configuration dynamically, mapping it into Info.plist and loading it inside the Swift AppDelegate.*

### 4. Build and Run
Ensure your simulator or physical device is connected, and run:
```bash
flutter pub get
flutter run
```

---

## 🧪 Running Tests
You can verify the calculations, translator fallbacks, and widget bindings by running:
```bash
flutter test
```
