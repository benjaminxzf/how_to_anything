# How To Anything — Flutter App

An interactive Flutter app that generates step‑by‑step “how to” tutorials using Google Gemini. It features a liquid search bar with optional image context, beautiful swipeable cards, and real‑time progress as images generate asynchronously.

Badges: Web | Android (iOS configuration WIP)

## Highlights

- Query + optional image context (camera/gallery)
- AI tutorial generation via Gemini 2.5 Flash (text)
- Step images via Gemini 2.5 Flash Image Preview (async, per‑step)
- Smooth swipeable UI with particle background and custom animations
- Provider state management with progress and error overlays
- Audio playback plumbing present; TTS generation not implemented yet

## Architecture & Flow

- Entry point: `lib/main.dart`
  - Loads `.env` using `flutter_dotenv` (expects `GEMINI_API_KEY`).
  - Initializes Firebase with `firebase_options.dart` (web/android configured; iOS placeholders).
  - Sets up `ChangeNotifierProvider<TutorialProvider>` and routes to `HomeScreen`.

- State: `lib/services/tutorial_provider.dart`
  - States: `idle | loading | completed | error` with progress text.
  - Orchestrates generation via `GeminiService.generateCompleteTutorial(...)`.
  - Returns tutorial immediately, then generates step images asynchronously.
  - Updates each step’s `imageUrl` via `onImageUpdate` and notifies listeners.

- Service: `lib/services/gemini_service.dart`
  - Text generation: `POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent`.
  - Image generation: `POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent`.
  - Accepts optional inline image context; cleans LLM output (strips code fences) and enforces JSON schema.
  - Web compatibility: deep‑converts IdentityMap to standard Map.
  - TTS method is stubbed; not implemented.

- UI
  - `HomeScreen`: liquid search bar (`widgets/liquid_search_bar.dart`) with camera/gallery using `image_picker`, animated background (`widgets/particle_field.dart`), generation overlay, and error overlay.
  - `TutorialScreen`: `card_swiper`‑based overview + per‑step cards (`widgets/tutorial_overview_card.dart`, `widgets/tutorial_step_card.dart`). Each step shows loading placeholder until its image arrives.

### Project Structure
```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── tutorial.dart
│   ├── tutorial.g.dart
│   ├── tutorial_step.dart
│   └── tutorial_step.g.dart
├── screens/
│   ├── home_screen.dart
│   └── tutorial_screen.dart
├── services/
│   ├── gemini_service.dart
│   └── tutorial_provider.dart
├── utils/
│   └── animation_utils.dart
└── widgets/
    ├── liquid_search_bar.dart
    ├── particle_field.dart
    ├── tutorial_generation_overlay.dart
    ├── tutorial_header.dart
    ├── tutorial_overview_card.dart
    ├── tutorial_step_card.dart
    └── step_indicator.dart
```

## Setup

Prerequisites
- Flutter (stable channel)
- Dart SDK >= 3.8 (pubspec `environment: sdk: ^3.8.1`)
- Google AI Studio API key (Generative Language API)

1) Install dependencies
```bash
cd how_to_anything_flutter
flutter pub get
```

2) Environment variables
Create `.env` in this folder and add:
```env
GEMINI_API_KEY=your_api_key
```
Note: `.env` is git‑ignored but must exist at build time (it’s declared under `flutter/assets`).

3) Firebase config
- `firebase_options.dart` contains working web/android config for a sample project. Replace with your own using FlutterFire CLI for production.
- iOS/macOS/windows have placeholder values — configure before targeting those platforms.

4) Generate JSON serialization code (if edited)
```bash
dart run build_runner build
```

## Run

Web
```bash
flutter run -d chrome
```

Android
```bash
flutter run -d android
```

Build
```bash
# Web
flutter build web --release

# Android
flutter build apk --release
```

Platform notes
- Android: `image_picker` handles camera/gallery; ensure camera permission is allowed. If needed, add `<uses-permission android:name="android.permission.CAMERA" />`.
- iOS: Add proper Firebase options and `NSCameraUsageDescription` for camera.

## Usage

- Enter a query like “how to tie a tie”.
- Optionally add a photo to guide the model.
- Text tutorial appears quickly; step images load one by one.
- Swipe through steps; tools/tips/warnings show per card.

## Configuration

Environment
```env
GEMINI_API_KEY=...
```

Models used
- Text: `gemini-2.5-flash`
- Images: `gemini-2.5-flash-image-preview`

Security
- Don’t commit real API keys. Use environment variables and restrict keys in your Google Cloud project (HTTP referrers/package name/signing cert as appropriate).

## Dependencies (from pubspec)

- firebase_core: ^4.1.0
- flutter_dotenv: ^5.1.0
- http: ^1.1.0
- provider: ^6.1.1
- card_swiper: ^3.0.1
- audioplayers: ^6.0.0
- image_picker: ^1.0.4
- cached_network_image: ^3.3.1
- shimmer: ^3.0.0
- json_annotation: ^4.8.1
- material_color_utilities: ^0.11.1
- dev: json_serializable ^6.7.1, build_runner ^2.4.7, flutter_lints

## Known Limitations

- TTS is not implemented; audio buttons appear only if an `audioUrl` is present.
- iOS/macOS/windows Firebase options are placeholders.
- Web may be subject to CORS or API key restrictions depending on your Google Cloud settings.
- Default widget test is boilerplate and doesn’t match `HowToAnythingApp` yet.

## Troubleshooting

- 401/403 from Gemini: verify `GEMINI_API_KEY` and API enablement.
- JSON parse errors: the model sometimes returns fenced code; we strip backticks and parse again.
- Images not loading: ensure the Image Preview model is enabled and quotas are available.

## Roadmap

- Server‑side TTS generation and audio per step
- Tutorial persistence/sharing
- Offline save for tutorials
- iOS/macOS/windows first‑class support

— Built with Flutter and Google Gemini
