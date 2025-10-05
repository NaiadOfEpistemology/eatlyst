# Eatlyst

**Eatlyst** is a modular, AI - powered calorie and nutrition built with Flutter. It combines real-time food logging, and a branded UX designed for operational realism and long-term maintainability.

## Features

- **Real-Time Logging**  
  Fast, intuitive input system with persistent state and responsive UI.
  
- **TensorFlow Model**  
  AI model trained upon the food101 dataset and converted to tflite for mobile use.

- **Offline Resilience**  
  Local caching and fallback logic ensure uninterrupted access in low to zero connectivity environments.

- **Safe System Integration**  
  Disk-aware build pipeline with automated cleanup and preservation of critical SDKs and dependencies.

## Model Foundation

Eatlyst’s recommendation engine is trained on the **Food-101 dataset**, a curated collection of 101 food categories with over 100,000 labeled images. This dataset provides a robust foundation for visual food recognition and classification, enabling the app to deliver context-aware suggestions and accurate logging support.

The model has been optimized for mobile deployment, with callbacks integrated into the Flutter pipeline for real-time inference and feedback. Preprocessing includes image normalization, resizing, and augmentation. The architecture is lightweight and tuned for low-latency inference on-device.

## Tech Stack

- Flutter 
- Xcode + iOS SDK 26.0 
- YAML + Asset Catalogs 

## Setup

1. Clone the repository  
  

2. Install dependencies  
   `flutter pub get`

3. Run on device  
   `flutter run -d <device_id>`

> For persistent installation, open `ios/Runner.xcworkspace` in Xcode and deploy directly to a physical device.

## Deployment Notes

- Simulator runtimes are supported but optional  
- USB device testing is preferred for persistent installs  

## Safety & Stability

Eatlyst is built with a safety-first mindset. Cleanup routines are modular and scoped to avoid critical SDKs. ML model caches and simulator volumes are managed with precision to preserve build integrity and disk space. All system-level operations are designed to be reversible and non-destructive.

## License

MIT License. See `LICENSE.md` for details.
Copyright © 2025 Tanvi V R Medapati.
