import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:split_it/Data/Datasources/Local/Entities/bill_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/bill_item_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/split_bill_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/summary_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/summary_item_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/user_entity.dart';
import 'package:split_it/Data/Datasources/Remote/Responses/deepseek_response.dart';
import 'package:split_it/Data/Repository/split_bill_repository.dart';
import 'package:split_it/Domain/Models/bill_item_model.dart';
import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Domain/Models/split_bill_model.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  group('SplitBillRepositoryImpl', () {
    late MockRemoteDatasources mockRemoteDatasources;
    late MockLocalDatasources mockLocalDatasources;
    late SplitBillRepositoryImpl repository;

    setUp(() {
      mockRemoteDatasources = MockRemoteDatasources();
      mockLocalDatasources = MockLocalDatasources();
      repository = SplitBillRepositoryImpl(
        remoteDatasources: mockRemoteDatasources,
        localDatasource: mockLocalDatasources,
      );
    });

    group('getBillItemModels', () {
      test('returns BillItemModel when API call is successful', () async {
        // Arrange
        final rawOcr = ['Test bill text', 'Total: \$50.00'];
        final mockResponse = DeepseekResponse(
          items: [BillItemResponse(name: 'itemName', quantity: 1, price: 1)],
          subtotal: 1,
          total: 1,
          service: 0,
          tax: 0,
          discount: 0,
          billName: 'Shop',
          currency: '\$',
          dateIssued: '00/00/0000',
        );

        when(
          mockRemoteDatasources.cleanOCRText(rawOcr),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        final result = await repository.getBillItemModels(rawOcr);
        expect(
          result,
          isA<BillItemModel>()
              .having((r) => r.billName, "bill name", "Shop")
              .having((r) => r.total, "total", 1),
        );
      });

      test('throws exception when API call fails', () async {
        // Arrange
        final rawOcr = ['Test bill text'];

        when(
          mockRemoteDatasources.cleanOCRText(rawOcr),
        ).thenThrow(Exception('API Error'));

        // Act & Assert
        expect(
          () => repository.getBillItemModels(rawOcr),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('Exception: API Error'),
            ),
          ),
        );
      });

      test('throws exception when OCR text is empty', () async {
        // Arrange
        final rawOcr = <String>[];

        when(
          mockRemoteDatasources.cleanOCRText(rawOcr),
        ).thenThrow(Exception('No text found in the image'));

        // Act & Assert
        expect(
          () => repository.getBillItemModels(rawOcr),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains(
                    'Exception: No text found in the image',
                  ),
            ),
          ),
        );
      });
    });

    group('createSplitBillEntity', () {
      test('returns bill ID when save is successful', () async {
        // Arrange
        final billItem = BillItemModel(
          items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
          subtotal: 10.0,
          service: 0.0,
          tax: 0.0,
          discount: 0.0,
          total: 10.0,
          billName: 'Test Bill',
          currency: '\$',
          dateIssued: '2024-01-01',
        );

        when(
          mockLocalDatasources.createOrUpdateSplitBill(any),
        ).thenAnswer((_) async => 'test-bill-id');

        // Act
        final result = await repository.createSplitBillEntity(billItem);

        // Assert
        expect(result, equals('test-bill-id'));
      });

      test('throws exception when local save fails', () async {
        // Arrange
        final billItem = BillItemModel(
          items: [],
          subtotal: 0,
          service: 0,
          tax: 0,
          discount: 0,
          total: 0,
          billName: '',
          currency: '',
          dateIssued: '',
        );

        when(
          mockLocalDatasources.createOrUpdateSplitBill(any),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.createSplitBillEntity(billItem),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('Exception: Database error'),
            ),
          ),
        );
      });
    });

    group('getBillDetail', () {
      test('returns SplitBillModel when bill exists', () async {
        // Arrange
        const billId = 'test-bill-id';
        final mockEntity = SplitBillEntity(
          id: 'test-bill-id',
          listUser: [UserEntity(name: 'name', image: 'image', id: 'id')],
          billEntity: BillEntity(
            items: [
              BillItemEntity(
                name: 'name',
                quantity: 1,
                price: 1,
                userIds: ['id'],
              ),
            ],
            subtotal: 1,
            service: 0,
            tax: 0,
            discount: 0,
            total: 1,
            billName: 'billName',
            currency: '\$',
            dateIssued: 'dateIssued',
          ),
        );

        when(
          mockLocalDatasources.getSplitBill(billId),
        ).thenAnswer((_) async => mockEntity);

        // Act & Assert
        final result = await repository.getBillDetail(billId);

        print(result.id);
        expect(
          result,
          isA<SplitBillModel>()
              .having((m) => m.id, "bill id", 'test-bill-id')
              .having((m) => m.billModel.billName, 'bill name', 'billName')
              .having((m) => m.billModel.total, 'total', 1),
        );
      });

      test('throws exception when bill not found', () async {
        // Arrange
        const billId = 'non-existent-id';

        when(
          mockLocalDatasources.getSplitBill(billId),
        ).thenThrow(Exception('Bill not found'));

        // Act & Assert
        expect(
          () => repository.getBillDetail(billId),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('Exception: Bill not found'),
            ),
          ),
        );
      });
    });

    group('deleteBill', () {
      test('deletes bill successfully', () async {
        // Arrange
        const billId = 'test-bill-id';

        when(mockLocalDatasources.deleteBill(billId)).thenAnswer((_) async {});

        // Act
        await repository.deleteBill(billId);

        // Assert
        verify(mockLocalDatasources.deleteBill(billId)).called(1);
      });

      test('throws exception when delete fails', () async {
        // Arrange
        const billId = 'test-bill-id';

        when(
          mockLocalDatasources.deleteBill(billId),
        ).thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(
          () => repository.deleteBill(billId),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('Exception: Delete failed'),
            ),
          ),
        );
        verify(mockLocalDatasources.deleteBill(billId)).called(1);
      });
    });

    group('getSummary', () {
      test('returns SummaryModel when entity exists', () async {
        // Arrange
        const summaryId = 'test-summary-id';
        final mockEntity = SummaryEntity(
          id: 'test-summary-id',
          userList: [UserEntity(name: 'name', image: 'image', id: 'id')],
          summaryList: [
            SummaryItemEntity(userId: 'id', totalOwned: 1, items: ['itemName']),
          ],
          billName: 'Shop',
          currency: '\$',
          dateIssued: '00/00/0000',
        );

        when(
          mockLocalDatasources.getSummary(summaryId),
        ).thenAnswer((_) async => mockEntity);

        // Act & Assert
        final result = await repository.getSummary(summaryId);
        expect(
          result,
          isA<SummaryModel>()
              .having((m) => m.id, "summary id", 'test-summary-id')
              .having((m) => m.billName, 'bill name', 'Shop')
              .having((m) => m.summaryList[0].totalOwned, 'total', 1),
        );
      });

      test('throws exception when summary not found', () async {
        // Arrange
        const summaryId = 'non-existent-id';

        when(
          mockLocalDatasources.getSummary(summaryId),
        ).thenThrow(Exception('Summary not found'));

        // Act & Assert
        expect(
          () => repository.getSummary(summaryId),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('Exception: Summary not found'),
            ),
          ),
        );
      });
    });

    group('getAllSummary', () {
      test('returns list of SummaryModel when summaries exist', () async {
        final mockEntity = SummaryEntity(
          id: 'test-summary-id',
          userList: [UserEntity(name: 'name', image: 'image', id: 'id')],
          summaryList: [
            SummaryItemEntity(userId: 'id', totalOwned: 1, items: ['itemName']),
          ],
          billName: 'Shop',
          currency: '\$',
          dateIssued: '00/00/0000',
        );

        when(
          mockLocalDatasources.getAllSummary(),
        ).thenAnswer((_) async => [mockEntity]);

        // Act
        final result = await repository.getAllSummary();

        // Assert
        expect(
          result,
          isA<List<SummaryModel>>()
              .having((e) => e[0].id, 'summary id', 'test-summary-id')
              .having((e) => e[0].billName, 'bill name', 'Shop'),
        );
        verify(mockLocalDatasources.getAllSummary()).called(1);
      });

      test('returns empty list when no summaries exist', () async {
        // Arrange
        when(mockLocalDatasources.getAllSummary()).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllSummary();

        // Assert
        expect(result, isEmpty);
      });

      test('throws exception when database query fails', () async {
        // Arrange
        when(
          mockLocalDatasources.getAllSummary(),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.getAllSummary(),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('Exception: Database error'),
            ),
          ),
        );
      });
    });

    group('deleteSummary', () {
      test('deletes summary successfully', () async {
        // Arrange
        const summaryId = 'test-summary-id';

        when(
          mockLocalDatasources.deleteSummary(summaryId),
        ).thenAnswer((_) async {});

        // Act
        await repository.deleteSummary(summaryId);

        // Assert
        verify(mockLocalDatasources.deleteSummary(summaryId)).called(1);
      });

      test('throws exception when delete fails', () async {
        // Arrange
        const summaryId = 'test-summary-id';

        when(
          mockLocalDatasources.deleteSummary(summaryId),
        ).thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(
          () => repository.deleteSummary(summaryId),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('Exception: Delete failed'),
            ),
          ),
        );
        verify(mockLocalDatasources.deleteSummary(summaryId)).called(1);
      });
    });
  });
}
