import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split_it/Data/Datasources/Remote/Responses/deepseek_response.dart';
import 'package:split_it/Data/Datasources/Remote/remote_datasources.dart';
import 'package:mockito/mockito.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  group('RemoteDatasources Response Parsing Tests', () {
    late MockNetworkCall mockNetworkCall;
    late RemoteDatasources remoteDatasources;

    setUp(() {
      mockNetworkCall = MockNetworkCall();
      remoteDatasources = RemoteDatasources(networkCall: mockNetworkCall);
    });
    group('BillItemResponse Tests', () {
      test('should parse bill item correctly', () {

        final itemJson = {'name': 'Test Item', 'quantity': 2, 'price': 15.50};

        final result = BillItemResponse.fromJson(itemJson);

        expect(result.name, equals('Test Item'));
        expect(result.quantity, equals(2));
        expect(result.price, equals(15.50));
      });

      test('should throw Exception when bill is empty', () async {
        final fakeApiResponse = {
          'choices': [
            {
              'message': {
                'content': jsonEncode({
                  'items': null,
                  'total': 10.0,
                  'bill_name': 'Mock Bill',
                  'currency': '\$',
                  'date_issued': '2024-01-01',
                }),
              },
            },
          ],
        };
        when(mockNetworkCall.post(any, data: anyNamed('data'))).thenAnswer(
          (_) async => Response(
            data: fakeApiResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final ocrText = ['Mocked OCR line 1', 'Mocked OCR line 2'];

        expect(
          () async => await remoteDatasources.cleanOCRText(ocrText),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains(
                    'Invalid bill image: Exception: No bill items found in the image',
                  ),
            ),
          ),
        );
      });

      test('should throw Exception when total is invalid', () async {
        final fakeApiResponse = {
          'choices': [
            {
              'message': {
                'content': jsonEncode({
                  'items': [
                    {'name': 'Mock Item', 'quantity': 2, 'price': 5.0},
                  ],
                  'total': 0,
                  'bill_name': 'Mock Bill',
                  'currency': '\$',
                  'date_issued': '2024-01-01',
                }),
              },
            },
          ],
        };
        when(mockNetworkCall.post(any, data: anyNamed('data'))).thenAnswer(
          (_) async => Response(
            data: fakeApiResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final ocrText = ['Mocked OCR line 1', 'Mocked OCR line 2'];

        expect(
          () async => await remoteDatasources.cleanOCRText(ocrText),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains(
                    'Invalid bill image: Exception: No valid total amount found in the image',
                  ),
            ),
          ),
        );
      });

      test('should throw Exception when json invalid', () async {
        when(
          mockNetworkCall.post(any, data: anyNamed('data')),
        ).thenThrow(Exception('Invalid json'));

        final ocrText = ['Mocked OCR line 1', 'Mocked OCR line 2'];
        expect(
          () async => await remoteDatasources.cleanOCRText(ocrText),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains(
                    'Invalid JSON returned: Exception: Invalid json',
                  ),
            ),
          ),
        );
      });

      test('should handle missing optional fields in bill item', () {
        // Arrange
        final itemJson = {'name': 'Test Item'};

        // Act
        final result = BillItemResponse.fromJson(itemJson);

        // Assert
        expect(result.name, equals('Test Item'));
        expect(result.quantity, isNull);
        expect(result.price, isNull);
      });
    });
  });

  group('RemoteDatasources Mocked API Test', () {
    late MockNetworkCall mockNetworkCall;
    late RemoteDatasources remoteDatasources;

    setUp(() {
      mockNetworkCall = MockNetworkCall();
      remoteDatasources = RemoteDatasources(networkCall: mockNetworkCall);
    });
    test('success API response from mock', () async {
      final fakeApiResponse = {
        'choices': [
          {
            'message': {
              'content': jsonEncode({
                'items': [
                  {'name': 'Mock Item', 'quantity': 2, 'price': 5.0},
                ],
                'total': 10.0,
                'bill_name': 'Mock Bill',
                'currency': '\$',
                'date_issued': '2024-01-01',
              }),
            },
          },
        ],
      };
      when(mockNetworkCall.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: fakeApiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final ocrText = ['Mocked OCR line 1', 'Mocked OCR line 2'];
      final result = await remoteDatasources.cleanOCRText(ocrText);
      expect(result, isA<DeepseekResponse>());
      expect(result.items, isNotNull);
      expect(result.items!.length, equals(1));
      expect(result.items![0].name, equals('Mock Item'));
      expect(result.total, equals(10.0));
      expect(result.billName, equals('Mock Bill'));
    });

    test('DIO EXCEPTION API response from mock', () async {
      final reqOptions = RequestOptions(path: '/test');
      when(
        mockNetworkCall.post(any, data: anyNamed('data')),
      ).thenThrow(DioException(requestOptions: reqOptions));

      final ocrText = ['Mocked OCR line 1', 'Mocked OCR line 2'];
      expect(
        () async => await remoteDatasources.cleanOCRText(ocrText),
        throwsA(isA<Exception>()),
      );
    });
  });
}
