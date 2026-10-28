import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EmotionScore {
  final String label;
  final double confidence;

  const EmotionScore({required this.label, required this.confidence});

  factory EmotionScore.fromJson(Map<String, dynamic> json) {
    final label = json['label'];
    final confidence = json['confidence'];
    if (label is! String || confidence is! num) {
      throw const FormatException('Invalid emotion score in API response.');
    }
    return EmotionScore(
      label: label,
      confidence: confidence.toDouble(),
    );
  }
}

class TextAnalysisResult {
  final String text;
  final String emotion;
  final double confidence;
  final List<EmotionScore> allEmotions;

  const TextAnalysisResult({
    required this.text,
    required this.emotion,
    required this.confidence,
    required this.allEmotions,
  });

  factory TextAnalysisResult.fromJson(Map<String, dynamic> json) {
    final text = json['text'];
    final emotion = json['emotion'];
    final confidence = json['confidence'];
    final scores = json['all_emotions'];
    if (text is! String ||
        emotion is! String ||
        confidence is! num ||
        scores is! List) {
      throw const FormatException('Invalid text analysis API response.');
    }

    return TextAnalysisResult(
      text: text,
      emotion: emotion,
      confidence: confidence.toDouble(),
      allEmotions: scores
          .map(
            (score) => EmotionScore.fromJson(
              Map<String, dynamic>.from(score as Map),
            ),
          )
          .toList(),
    );
  }
}

class TextAnalysisException implements Exception {
  final String message;

  const TextAnalysisException(this.message);

  @override
  String toString() => message;
}

class TextAnalysisService {
  final http.Client _client;

  TextAnalysisService({http.Client? client}) : _client = client ?? http.Client();

  static String get defaultBaseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      const configuredAndroidUrl = String.fromEnvironment(
        'TEXT_ANALYSIS_API_URL',
        defaultValue: 'http://192.168.1.3:8000',
      );
      return configuredAndroidUrl;
    }
    return 'http://127.0.0.1:8000';
  }

  Future<TextAnalysisResult> analyze({
    required String baseUrl,
    required String text,
  }) async {
    final uri = _analysisUri(baseUrl);
    late final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 120));
    } on TimeoutException {
      throw const TextAnalysisException(
        'The request timed out. Make sure the API is running and try again.',
      );
    } on http.ClientException {
      throw const TextAnalysisException(
        'Could not connect to the API. Check the server address and make sure '
        'the FastAPI server is running.',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const TextAnalysisException(
        'The API returned an unreadable response.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded is Map ? decoded['detail'] : null;
      throw TextAnalysisException(
        detail is String
            ? 'API error (${response.statusCode}): $detail'
            : 'API request failed with status ${response.statusCode}.',
      );
    }

    if (decoded is! Map) {
      throw const TextAnalysisException(
        'The API response did not contain an analysis result.',
      );
    }
    try {
      return TextAnalysisResult.fromJson(Map<String, dynamic>.from(decoded));
    } on FormatException catch (error) {
      throw TextAnalysisException(error.message);
    } on TypeError {
      throw const TextAnalysisException(
        'The API returned an invalid emotion score.',
      );
    }
  }

  Uri _analysisUri(String baseUrl) {
    final Uri baseUri;
    try {
      baseUri = Uri.parse(baseUrl.trim());
    } on FormatException {
      throw const TextAnalysisException('Enter a valid API base URL.');
    }

    if (!baseUri.isAbsolute ||
        !{'http', 'https'}.contains(baseUri.scheme) ||
        baseUri.host.isEmpty ||
        baseUri.hasQuery ||
        baseUri.hasFragment ||
        baseUri.userInfo.isNotEmpty) {
      throw const TextAnalysisException(
        'Enter a valid API base URL, for example http://10.0.2.2:8000.',
      );
    }

    final basePath = baseUri.path.replaceFirst(RegExp(r'/+$'), '');
    return baseUri.replace(path: '$basePath/analyze');
  }

  void close() => _client.close();
}
