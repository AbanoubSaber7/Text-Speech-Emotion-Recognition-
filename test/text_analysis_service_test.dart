import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mood_app/services/text_analysis_service.dart';

void main() {
  test('posts text and parses all emotion scores', () async {
    final service = TextAnalysisService(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/analyze');
        expect(jsonDecode(request.body), {'text': 'I feel happy today.'});
        return http.Response(
          jsonEncode({
            'text': 'I feel happy today.',
            'emotion': 'joy',
            'confidence': 98.66,
            'all_emotions': [
              {'label': 'joy', 'confidence': 98.66},
              {'label': 'sadness', 'confidence': 0.2},
            ],
          }),
          200,
        );
      }),
    );
    addTearDown(service.close);

    final result = await service.analyze(
      baseUrl: 'http://127.0.0.1:8000/',
      text: 'I feel happy today.',
    );

    expect(result.emotion, 'joy');
    expect(result.confidence, 98.66);
    expect(result.allEmotions, hasLength(2));
    expect(result.allEmotions.last.label, 'sadness');
  });

  test('shows API validation details', () async {
    final service = TextAnalysisService(
      client: MockClient(
        (_) async => http.Response('{"detail":"Invalid text"}', 422),
      ),
    );
    addTearDown(service.close);

    expect(
      () => service.analyze(baseUrl: 'http://127.0.0.1:8000', text: '   '),
      throwsA(
        isA<TextAnalysisException>().having(
          (error) => error.message,
          'message',
          contains('Invalid text'),
        ),
      ),
    );
  });

  test('rejects invalid API addresses', () async {
    final service = TextAnalysisService(
      client: MockClient((_) async {
        fail('The request must not be sent for an invalid address.');
      }),
    );
    addTearDown(service.close);

    expect(
      () => service.analyze(baseUrl: 'not a URL', text: 'hello'),
      throwsA(isA<TextAnalysisException>()),
    );
  });
}
