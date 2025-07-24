import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:split_it/Data/Datasources/Remote/network/dio.dart';

class MockDio extends Mock implements Dio {}

class MockResponse<T> extends Mock implements Response<T> {}

void main() {
  late MockDio mockDio;
  late NetworkCall networkCall;

  setUp(() async {
    mockDio = MockDio();
    networkCall = NetworkCall.test(mockDio);

    // Override dio instance with mock
    networkCall.dio = mockDio;
  });

  group('NetworkCall', () {
    test('get() should call dio.get with correct parameters', () async {
      final response = MockResponse<String>();
      when(
        () => mockDio.get<String>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => response);

      final result = await networkCall.get<String>(
        '/test',
        queryParameters: {'q': 'value'},
      );

      expect(result, response);
      verify(
        () => mockDio.get<String>(
          '/test',
          queryParameters: {'q': 'value'},
          options: null,
        ),
      ).called(1);
    });

    test('post() should call dio.post with correct parameters', () async {
      final response = MockResponse<String>();
      when(
        () => mockDio.post<String>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => response);

      final result = await networkCall.post<String>(
        '/test',
        data: {'key': 'value'},
      );

      expect(result, response);
      verify(
        () => mockDio.post<String>(
          '/test',
          data: {'key': 'value'},
          options: null,
        ),
      ).called(1);
    });

    test('put() should call dio.put with correct parameters', () async {
      final response = MockResponse<String>();
      when(
        () => mockDio.put<String>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => response);

      final result = await networkCall.put<String>(
        '/test',
        data: {'key': 'value'},
      );

      expect(result, response);
      verify(
        () =>
            mockDio.put<String>('/test', data: {'key': 'value'}, options: null),
      ).called(1);
    });

    test('delete() should call dio.delete with correct parameters', () async {
      final response = MockResponse<String>();
      when(
        () => mockDio.delete<String>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => response);

      final result = await networkCall.delete<String>(
        '/test',
        data: {'key': 'value'},
      );

      expect(result, response);
      verify(
        () => mockDio.delete<String>(
          '/test',
          data: {'key': 'value'},
          options: null,
        ),
      ).called(1);
    });
  });
}
