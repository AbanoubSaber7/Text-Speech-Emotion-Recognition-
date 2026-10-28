# Current Mood - Requirements and Running Guide

## 1. Project Overview

Current Mood is a Flutter application for exploring emotions through facial
images, voice recordings, and English text. It can also provide
emotion-related recommendations and uses Firebase for account and cloud
features.

The face and voice emotion models run in the Flutter app. English text emotion
analysis is provided by an optional, separate Python API. The text model
estimates emotions expressed in text; it is not a mental-health diagnostic
tool.

## 2. Requirements

| Software / Requirement | Version or Details | Download |
|---|---|---|
| Flutter SDK | A Flutter release that includes Dart SDK `3.9.2` or newer | [Install Flutter](https://docs.flutter.dev/get-started/install) |
| Dart SDK | `^3.9.2`; included with Flutter | Included with Flutter |
| Android Studio | A recent version, including Android SDK and Android Platform Tools | [Download Android Studio](https://developer.android.com/studio) |
| Java Development Kit | JDK 17 recommended; Android Studio's bundled JBR can be used | Included with Android Studio |
| Git | Any recent version, if cloning the repository | [Download Git](https://git-scm.com/downloads) |
| Android device or emulator | USB debugging enabled on a physical device, or a configured Android emulator | Android Studio Device Manager |

The Android project uses Gradle 8.12 and Android Gradle Plugin 8.9.1. Android
Studio should be configured to use JDK 17 for Gradle.

### Optional: Text Analysis API

The text-analysis screen requires a separate Python API:

| Software / Requirement | Version or Details | Download |
|---|---|---|
| Python | Python 3.10 or newer recommended | [Download Python](https://www.python.org/downloads/) |
| Internet connection | Required to install Python packages and download the emotion model on first startup | — |

The API uses FastAPI, Uvicorn, Transformers, and PyTorch. Its dependencies are
listed in `current_mood_api/requirements.txt`.

## 3. Prepare the Flutter Project

1. Install Flutter and Android Studio.
2. Open the project root folder in Android Studio or VS Code.
3. If this is a fresh clone, install Flutter packages from a terminal in the
   project root:

   ```bash
   flutter pub get
   ```

4. Confirm that Flutter can find the required tools and device:

   ```bash
   flutter doctor
   flutter devices
   ```

5. Connect an Android phone with USB debugging enabled, or start an Android
   emulator.

### Firebase Configuration

The app uses Firebase Authentication, Cloud Firestore, and Firebase Storage.
This project includes Firebase configuration files for its configured Firebase
project. If using a different Firebase project, replace the Firebase
configuration with files generated for that project:

- `lib/firebase_options.dart`
- `android/app/google-services.json`

Enable the Firebase Authentication providers and configure the required
Firestore and Storage rules in the Firebase console.

## 4. Run the Flutter Application

From the project root, run:

```bash
flutter run
```

If more than one device is connected, choose a device explicitly:

```bash
flutter devices
flutter run -d <device-id>
```

The first Android build may take several minutes while Gradle downloads build
dependencies. After the build completes, Flutter installs and starts the app
on the selected device.

## 5. Run the Optional Text Analysis API

Open a second terminal and change to the API folder:

```powershell
cd current_mood_api
py -m venv venv
.\venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
uvicorn main:app --host 127.0.0.1 --port 8000
```

If PowerShell prevents virtual-environment activation, run the commands
through its Python executable instead:

```powershell
.\venv\Scripts\python.exe -m pip install --upgrade pip
.\venv\Scripts\python.exe -m pip install -r requirements.txt
.\venv\Scripts\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8000
```

The first API startup downloads the model
`j-hartmann/emotion-english-distilroberta-base` from Hugging Face. Wait until
the model-loaded and Uvicorn-started messages appear. Keep the API terminal
open while using text analysis.

### Connect a Physical Android Phone to the API

The phone and computer must be on the same Wi-Fi network.

1. Find the computer's IPv4 address by running `ipconfig` in PowerShell.
2. Start the API so that it accepts connections from the local network:

   ```powershell
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```

3. In the Flutter project terminal, run the app with the computer's address:

   ```powershell
   flutter run --dart-define=TEXT_ANALYSIS_API_URL=http://<computer-ip>:8000
   ```

   Replace `<computer-ip>` with the computer's actual IPv4 address, for
   example `192.168.1.3`.

4. If Windows Firewall prompts for access, allow the local network connection.

For an Android emulator, use the emulator's host address instead:

```powershell
flutter run --dart-define=TEXT_ANALYSIS_API_URL=http://10.0.2.2:8000
```

If the API's default port is changed from `8000`, use the new port in both the
Uvicorn command and the Flutter API URL.

## 6. Test the API

With the API running, open <http://127.0.0.1:8000/docs> on the computer running
the API. Expand `POST /analyze`, select **Try it out**, and submit:

```json
{
  "text": "I feel lonely and sad today."
}
```

The response includes the highest-scoring emotion and scores for all seven
emotion labels: anger, disgust, fear, joy, neutral, sadness, and surprise.
Scores are percentages and may vary.

## 7. Notes

- The Flutter application can run without the text API. Only the Text Analysis
  feature requires that API.
- The face and voice models are bundled with the Flutter app under `assets/`.
- The text API analyzes English text. Do not treat its predictions as a
  clinical diagnosis or medical advice.
- Do not expose the development API directly to the public internet. For
  production or remote access, deploy it behind HTTPS with appropriate
  security and access controls.
- For troubleshooting, run `flutter doctor`, check that the correct Android
  device is listed by `flutter devices`, and confirm that the API terminal
  reports a successful startup.
