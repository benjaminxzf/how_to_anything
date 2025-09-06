# How To Anything — Flutter App

An interactive Flutter application that generates step‑by‑step tutorials using Google Gemini. It features a liquid search bar with optional image context, swipeable tutorial cards, and live image generation per step.

This repository’s Flutter app lives in `how_to_anything_flutter/`.

## Features

- AI tutorial generation via Gemini 2.5 Flash (text)
- Optional image context (camera/gallery) to guide results
- Asynchronous step image generation with progress overlay
- Swipeable overview and per‑step cards with tips/warnings/tools
- Provider‑based state management and graceful error handling

## Quick Start

Prerequisites
- Flutter (stable)
- Dart >= 3.8
- Google AI Studio API key (Generative Language API)

Setup
```bash
cd how_to_anything_flutter
flutter pub get
```

Create `.env` in `how_to_anything_flutter/`:
```env
GEMINI_API_KEY=your_api_key
```

Run (Web)
```bash
flutter run -d chrome
```

Run (Android)
```bash
flutter run -d android
```

Production builds
```bash
# Web
flutter build web --release

# Android
flutter build apk --release
```

## Configuration Notes

- Firebase is initialized via `lib/firebase_options.dart` (web/android configured; iOS/macOS/windows are placeholders).
- `.env` is declared as a Flutter asset; ensure it exists at runtime.
- If targeting camera on Android/iOS, ensure camera permissions are configured.

## Docs

For architecture details, dependencies, troubleshooting, and roadmap, see `how_to_anything_flutter/README.md`.
