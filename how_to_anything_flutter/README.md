# How To Anything - Flutter App

A modern Flutter application that generates AI-powered step-by-step tutorials with interactive swipeable cards. Built with Firebase AI (Gemini 2.5) for intelligent content generation.

![Flutter](https://img.shields.io/badge/Flutter-3.32.8-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-AI-orange.svg)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android-lightgrey.svg)

## ✨ Features

- **🔍 Search Interface**: Clean, intuitive search bar inspired by modern design patterns
- **🤖 AI-Powered Content**: Uses Gemini 2.5 Flash for intelligent tutorial generation
- **📱 Swipeable Cards**: Interactive tutorial steps with smooth card transitions
- **🎨 Modern UI**: Material Design 3 with beautiful gradients and animations
- **🔊 Audio Integration**: Ready for voice narration (TTS integration planned)
- **🖼️ Image Support**: Prepared for AI-generated step images
- **📊 Progress Tracking**: Visual progress indicators and step navigation
- **⚡ Real-time Generation**: Live progress updates during content creation
- **🌐 Cross-Platform**: Runs on web and Android with responsive design

## 🏗️ Architecture

### Project Structure
```
lib/
├── models/              # Data models for Tutorial and TutorialStep
│   ├── tutorial.dart
│   ├── tutorial.g.dart
│   ├── tutorial_step.dart
│   └── tutorial_step.g.dart
├── screens/             # Main application screens
│   ├── home_screen.dart
│   └── tutorial_screen.dart
├── services/            # Business logic and API integration
│   ├── gemini_service.dart
│   └── tutorial_provider.dart
├── widgets/             # Reusable UI components
│   ├── tutorial_generation_overlay.dart
│   ├── tutorial_header.dart
│   ├── tutorial_step_card.dart
│   └── step_indicator.dart
├── firebase_options.dart
└── main.dart
```

### Key Components

#### 🧠 GeminiService
- Firebase AI integration for text generation
- JSON schema validation for consistent output
- Error handling and response parsing
- Ready for image and audio generation

#### 🎯 TutorialProvider  
- State management using Provider pattern
- Loading states and progress tracking
- Error handling with user-friendly messages

#### 🎨 UI Components
- **HomeScreen**: Search interface with gradient background
- **TutorialScreen**: Swipeable cards with navigation controls
- **TutorialStepCard**: Rich content display with tips and warnings
- **Custom Overlays**: Loading and error state management

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.32.8+
- Firebase project with AI services enabled
- Dart SDK 3.8.1+

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd how_to_anything_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   Create a `.env` file in the root directory:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

4. **Configure Firebase** (if needed)
   Update `firebase_options.dart` with your Firebase project configuration

5. **Generate model files**
   ```bash
   dart run build_runner build
   ```

### Running the App

#### Web Development
```bash
flutter run -d chrome
```

#### Android Development  
```bash
flutter run -d android
```

#### Production Build
```bash
# Web
flutter build web --release

# Android
flutter build apk --release
```

## 🎯 Usage

1. **Launch the app** - You'll see the beautiful search interface
2. **Enter a query** - Type "how to..." followed by what you want to learn
3. **Wait for generation** - AI creates a comprehensive tutorial in real-time
4. **Navigate the tutorial** - Swipe through interactive cards with rich content
5. **Complete the tutorial** - Track your progress and celebrate completion!

### Example Queries
- "how to tie a tie"
- "how to make coffee"  
- "how to change a tire"
- "how to fold origami"
- "how to cook pasta"

## 🔧 Configuration

### Firebase AI Setup
The app uses Firebase AI for content generation. Make sure your Firebase project has:
- Gemini API enabled
- Proper authentication configured
- API key with appropriate permissions

### Environment Variables
Add your API credentials to the `.env` file:
```env
GEMINI_API_KEY=AIzaSy...your_key_here
```

## 🎨 Customization

### Theme Configuration
The app uses Material Design 3 with a custom color scheme:
- Primary: Indigo (#6366F1)  
- Secondary: Violet (#8B5CF6)
- Background gradients and animations

### Adding New Features
1. **Custom Tutorial Types**: Extend the Tutorial model
2. **New UI Components**: Add to the widgets directory
3. **Additional Services**: Integrate with services directory
4. **Platform Features**: Use platform-specific implementations

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart
```

## 📦 Dependencies

### Core Dependencies
- `firebase_core: ^3.9.0` - Firebase initialization
- `firebase_ai: ^2.3.0` - AI services integration
- `provider: ^6.1.1` - State management
- `card_swiper: ^3.0.1` - Swipeable card interface

### UI/UX Dependencies  
- `shimmer: ^3.0.0` - Loading animations
- `cached_network_image: ^3.3.1` - Image caching
- `audioplayers: ^6.0.0` - Audio playback

### Development Dependencies
- `json_serializable: ^6.7.1` - Model serialization
- `build_runner: ^2.4.7` - Code generation

## 🌟 Future Enhancements

- **🖼️ Image Generation**: AI-generated step images using Gemini 2.5 Flash Image
- **🔊 Voice Narration**: Text-to-Speech integration with multiple voices
- **💾 Offline Support**: Save tutorials for offline viewing
- **👥 Social Features**: Share and rate tutorials
- **🎯 Personalization**: Adaptive difficulty and custom preferences
- **📊 Analytics**: Usage tracking and improvement insights

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Google Gemini AI** for powerful content generation
- **Firebase** for seamless backend integration  
- **Flutter Team** for the amazing framework
- **Material Design** for beautiful UI components

---

**Built with ❤️ using Flutter and Firebase AI**

For questions or support, please open an issue on GitHub.