import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  test('your test here', () async {
    final client = MockClient();

    when(client.get(Uri.parse('http://example.com')))
        .thenAnswer((_) async => http.Response('{"message": "ok"}', 200));

    final response = await client.get(Uri.parse('http://example.com'));

    expect(response.statusCode, equals(200));
  });
}