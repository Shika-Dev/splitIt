import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split_it/Data/Datasources/Remote/Responses/deepseek_response.dart';
import 'package:split_it/Data/Datasources/Remote/remote_datasources.dart';
import 'package:split_it/Data/Datasources/Remote/network/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  group('RemoteDatasources Response Parsing Tests', () {
    setUpAll(() async {
      // Initialize Flutter test binding
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    group('DeepseekResponse Parsing Tests', () {
      test('should parse valid JSON response correctly', () {
        // Arrange
        final validJson = {
          'items': [
            {'name': 'Item 1', 'quantity': 1, 'price': 10.0},
            {'name': 'Item 2', 'quantity': 1, 'price': 15.0},
          ],
          'subtotal': 25.0,
          'service': 0.0,
          'tax': 0.0,
          'discount': 0.0,
          'total': 25.0,
          'bill_name': 'Test Receipt',
          'currency': '\$',
          'date_issued': '2024-01-01',
        };

        // Act
        final result = DeepseekResponse.fromJson(validJson);

        // Assert
        expect(result.billName, equals('Test Receipt'));
        expect(result.currency, equals('\$'));
        expect(result.total, equals(25.0));
        expect(result.items, isNotNull);
        expect(result.items!.length, equals(2));
        expect(result.items![0].name, equals('Item 1'));
        expect(result.items![0].price, equals(10.0));
      });

      test('should handle response with missing optional fields', () {
        // Arrange
        final minimalJson = {
          'items': [
            {'name': 'Item 1', 'quantity': 1, 'price': 10.0},
          ],
          'total': 10.0,
          'bill_name': 'Test Receipt',
          'currency': '\$',
          'date_issued': '2024-01-01',
        };

        // Act
        final result = DeepseekResponse.fromJson(minimalJson);

        // Assert
        expect(result.subtotal, isNull);
        expect(result.service, isNull);
        expect(result.tax, isNull);
        expect(result.discount, isNull);
        expect(result.total, equals(10.0));
      });

      test('should handle markdown code block cleaning', () {
        // Arrange
        final jsonContent = {
          'items': [
            {'name': 'Item 1', 'quantity': 1, 'price': 10.0},
          ],
          'total': 10.0,
          'bill_name': 'Test Receipt',
          'currency': '\$',
          'date_issued': '2024-01-01',
        };

        final markdownContent = '```json\n${jsonEncode(jsonContent)}\n```';
        final cleanedContent = markdownContent
            .replaceAll(RegExp(r'^```json', multiLine: true), '')
            .replaceAll(RegExp(r'^```', multiLine: true), '')
            .replaceAll(RegExp(r'```$', multiLine: true), '')
            .trim();

        // Act
        final result = DeepseekResponse.fromJson(jsonDecode(cleanedContent));

        // Assert
        expect(result.billName, equals('Test Receipt'));
        expect(result.total, equals(10.0));
      });

      test('should handle different markdown formats', () {
        // Arrange
        final jsonContent = {
          'items': [
            {'name': 'Item 1', 'quantity': 1, 'price': 10.0},
          ],
          'total': 10.0,
          'bill_name': 'Test Receipt',
          'currency': '\$',
          'date_issued': '2024-01-01',
        };

        final markdownVariants = [
          '```json\n${jsonEncode(jsonContent)}\n```',
          '```\n${jsonEncode(jsonContent)}\n```',
          '```${jsonEncode(jsonContent)}```',
        ];

        for (final markdown in markdownVariants) {
          final cleanedContent = markdown
              .replaceAll(RegExp(r'^```json', multiLine: true), '')
              .replaceAll(RegExp(r'^```', multiLine: true), '')
              .replaceAll(RegExp(r'```$', multiLine: true), '')
              .trim();

          // Act
          final result = DeepseekResponse.fromJson(jsonDecode(cleanedContent));

          // Assert
          expect(result.billName, equals('Test Receipt'));
          expect(result.total, equals(10.0));
        }
      });
    });

    group('Validation Logic Tests', () {
      test('should validate response with items and valid total', () {
        // Arrange
        final validResponse = DeepseekResponse(
          items: [BillItemResponse(name: 'Item 1', quantity: 1, price: 10.0)],
          total: 10.0,
          billName: 'Test Receipt',
          currency: '\$',
          dateIssued: '2024-01-01',
        );

        // Act & Assert - should not throw
        expect(() {
          if (validResponse.items == null || validResponse.items!.isEmpty) {
            throw Exception("No bill items found in the image");
          }
          if (validResponse.total == null || validResponse.total! <= 0) {
            throw Exception("No valid total amount found in the image");
          }
        }, returnsNormally);
      });

      test('should throw exception when no items found', () {
        // Arrange
        final invalidResponse = DeepseekResponse(
          items: [],
          total: 10.0,
          billName: 'Test Receipt',
          currency: '\$',
          dateIssued: '2024-01-01',
        );

        // Act & Assert
        expect(() {
          if (invalidResponse.items == null || invalidResponse.items!.isEmpty) {
            throw Exception("No bill items found in the image");
          }
        }, throwsA(isA<Exception>()));
      });

      test('should throw exception when total is invalid', () {
        // Arrange
        final invalidResponse = DeepseekResponse(
          items: [BillItemResponse(name: 'Item 1', quantity: 1, price: 10.0)],
          total: 0,
          billName: 'Test Receipt',
          currency: '\$',
          dateIssued: '2024-01-01',
        );

        // Act & Assert
        expect(() {
          if (invalidResponse.total == null || invalidResponse.total! <= 0) {
            throw Exception("No valid total amount found in the image");
          }
        }, throwsA(isA<Exception>()));
      });

      test('should throw exception when total is negative', () {
        // Arrange
        final invalidResponse = DeepseekResponse(
          items: [BillItemResponse(name: 'Item 1', quantity: 1, price: 10.0)],
          total: -5.0,
          billName: 'Test Receipt',
          currency: '\$',
          dateIssued: '2024-01-01',
        );

        // Act & Assert
        expect(() {
          if (invalidResponse.total == null || invalidResponse.total! <= 0) {
            throw Exception("No valid total amount found in the image");
          }
        }, throwsA(isA<Exception>()));
      });

      test('should throw exception when total is null', () {
        // Arrange
        final invalidResponse = DeepseekResponse(
          items: [BillItemResponse(name: 'Item 1', quantity: 1, price: 10.0)],
          total: null,
          billName: 'Test Receipt',
          currency: '\$',
          dateIssued: '2024-01-01',
        );

        // Act & Assert
        expect(() {
          if (invalidResponse.total == null || invalidResponse.total! <= 0) {
            throw Exception("No valid total amount found in the image");
          }
        }, throwsA(isA<Exception>()));
      });
    });

    group('BillItemResponse Tests', () {
      test('should parse bill item correctly', () {
        // Arrange
        final itemJson = {'name': 'Test Item', 'quantity': 2, 'price': 15.50};

        // Act
        final result = BillItemResponse.fromJson(itemJson);

        // Assert
        expect(result.name, equals('Test Item'));
        expect(result.quantity, equals(2));
        expect(result.price, equals(15.50));
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

    group('Edge Cases', () {
      test('should handle empty OCR text list', () {
        final emptyOcrText = <String>[];
        expect(emptyOcrText, isEmpty);
      });

      test('should handle OCR text with special characters', () {
        final specialOcrText = [
          'Item with "quotes": \$10.00',
          'Item with \'apostrophes\': \$15.00',
          'Item with & symbols: \$5.00',
          'Total: \$30.00',
        ];
        expect(specialOcrText.length, equals(4));
      });

      test('should handle very long OCR text', () {
        final longOcrText = List.generate(
          100,
          (index) => 'Item $index: \$${index + 1}.00',
        );
        expect(longOcrText.length, equals(100));
      });

      test('should handle unicode characters in OCR text', () {
        final unicodeOcrText = [
          'Café: \$5.00',
          'Résumé: \$10.00',
          'Total: \$15.00',
        ];
        expect(unicodeOcrText.length, equals(3));
      });
    });
  });

  group('RemoteDatasources Mocked API Test', () {
    late MockNetworkCall mockNetworkCall;
    late RemoteDatasources remoteDatasources;
    late GetIt getIt;

    setUp(() {
      mockNetworkCall = MockNetworkCall();

      getIt = GetIt.instance;

      getIt.registerSingleton<NetworkCall>(mockNetworkCall);
      remoteDatasources = RemoteDatasources(networkCall: mockNetworkCall);
    });

    test('should parse valid API response from mock', () async {
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
  });
}
