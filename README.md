# imposter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Codemagic deployment setup

This repository now includes `codemagic.yaml` with an `android-release` workflow that:

- installs dependencies
- runs `flutter analyze`
- runs `flutter test`
- builds a release Android App Bundle (`.aab`)

### 1) Connect repository

In Codemagic, add this GitHub repository and choose the `codemagic.yaml` configuration.

### 2) Set Flutter/Android signing secrets in Codemagic

Add these environment variables in Codemagic (Team or App level):

- `CM_KEYSTORE_PATH` (keystore file path provided by Codemagic for your uploaded keystore)
- `CM_KEYSTORE_PASSWORD`
- `CM_KEY_ALIAS`
- `CM_KEY_PASSWORD`

If these are not set, the workflow still builds, but uses debug signing and is not suitable for Play Store deployment.

### 3) Trigger build

Run the `android-release` workflow from Codemagic UI.  
The generated `.aab` will be available in build artifacts.

### 4) Before publishing to stores

- Replace default app IDs (`com.example.imposter`) with your production identifiers in:
  - `android/app/build.gradle.kts`
  - `ios/Runner.xcodeproj/project.pbxproj`
- Configure store publishing integrations in Codemagic (Google Play / App Store Connect) when ready.
