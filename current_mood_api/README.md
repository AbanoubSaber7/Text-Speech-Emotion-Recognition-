# Current Mood Text Emotion API

This is a separate Python service for classifying emotions expressed in English
text. It does not replace the Flutter app's existing face/voice TFLite models
and is not a mental-health diagnostic tool.

## Run on Windows with PowerShell

Open a terminal in this `current_mood_api` folder, then run:

```powershell
py -m venv venv
.\venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
uvicorn main:app --host 127.0.0.1 --port 8000
```

If PowerShell blocks activation, skip activation and run the virtual
environment's Python directly:

```powershell
.\venv\Scripts\python.exe -m pip install --upgrade pip
.\venv\Scripts\python.exe -m pip install -r requirements.txt
.\venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000
```

The first server start downloads the model from Hugging Face and may take a
while. Wait for `Emotion model loaded successfully!` and the Uvicorn startup
message.

Keep this terminal running while testing the Flutter app. On Android, the app
uses `http://192.168.1.3:8000` by default for the current development network.
If the computer's IP changes, pass its new address when launching Flutter:

```powershell
flutter run --dart-define=TEXT_ANALYSIS_API_URL=http://<computer-ip>:8000
```

For the Android emulator, use its host alias instead:

```powershell
flutter run --dart-define=TEXT_ANALYSIS_API_URL=http://10.0.2.2:8000
```

For a physical phone on the same Wi-Fi network, find the computer's local IPv4
address with `ipconfig`; start the API with `--host 0.0.0.0` as shown above and
allow the connection through Windows Firewall if prompted. Do not expose this
development server to the public internet; use an HTTPS deployment for
production.

## Test the API

Open <http://127.0.0.1:8000/docs>, expand `POST /analyze`, select **Try it out**,
and submit:

```json
{
  "text": "I feel lonely and sad today."
}
```

The response contains the highest-scoring emotion and scores for all seven
emotions. Scores are percentages and may vary slightly.

`127.0.0.1` is available only on the computer running the API. For Flutter web,
add the app's exact origin to the server's comma-separated `CORS_ORIGINS`
environment variable when it is not running on localhost.
