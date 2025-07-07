import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:split_it/Data/Datasources/Local/Entities/bill_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/bill_item_entity.dart';
import 'package:split_it/Data/Datasources/Local/local_datasources.dart';
import 'package:split_it/Data/Datasources/Local/Entities/split_bill_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/summary_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/summary_item_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/user_entity.dart';

void main() {
  group('LocalDatasources Integration Tests', () {
    late LocalDatasources localDatasources;

    setUpAll(() async {
      // Initialize Flutter test binding
      TestWidgetsFlutterBinding.ensureInitialized();

      // Initialize Hive for testing with a simple path
      Hive.init('./test_hive');

      // Register adapters
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(SplitBillEntityAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(SummaryEntityAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(UserEntityAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(BillItemEntityAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(BillEntityAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(SummaryItemEntityAdapter());
      }
    });

    setUp(() async {
      // Open boxes for testing
      await Hive.openBox<SplitBillEntity>('splitBillBox');
      await Hive.openBox<SummaryEntity>('summaryBox');
      localDatasources = LocalDatasources();
    });

    tearDown(() async {
      // Clear boxes after each test
      await Hive.box<SplitBillEntity>('splitBillBox').clear();
      await Hive.box<SummaryEntity>('summaryBox').clear();
    });

    tearDownAll(() async {
      // Close boxes and Hive
      await Hive.close();
    });

    group('Split Bill Operations', () {
      late SplitBillEntity testSplitBill;
      late BillEntity testBill;
      late List<UserEntity> testUsers;

      setUp(() {
        testBill = BillEntity(
          billName: 'Test Bill',
          items: [
            BillItemEntity(
              name: 'Item 1',
              quantity: 2,
              price: 10.0,
              userIds: ['user1'],
            ),
          ],
          subtotal: 20.0,
          service: 2.0,
          tax: 1.0,
          discount: 0.0,
          total: 23.0,
          currency: '\$',
          dateIssued: '2024-01-01',
        );

        testUsers = [
          UserEntity(id: 'user1', name: 'John', image: 'image1'),
          UserEntity(id: 'user2', name: 'Jane', image: 'image2'),
        ];

        testSplitBill = SplitBillEntity(
          id: 'split1',
          listUser: testUsers,
          billEntity: testBill,
        );
      });

      group('createOrUpdateSplitBill', () {
        test('should successfully create a new split bill', () async {
          // Act
          final result = await localDatasources.createOrUpdateSplitBill(
            testSplitBill,
          );

          // Assert
          expect(result, equals('split1'));

          // Verify it was actually saved
          final savedBill = await localDatasources.getSplitBill('split1');
          expect(savedBill.id, equals('split1'));
          expect(savedBill.billEntity.billName, equals('Test Bill'));
        });

        test('should successfully update an existing split bill', () async {
          // Arrange - create initial bill
          await localDatasources.createOrUpdateSplitBill(testSplitBill);

          // Create updated bill
          final updatedBill = SplitBillEntity(
            id: 'split1',
            listUser: testUsers,
            billEntity: BillEntity(
              billName: 'Updated Test Bill',
              items: testBill.items,
              subtotal: testBill.subtotal,
              service: testBill.service,
              tax: testBill.tax,
              discount: testBill.discount,
              total: testBill.total,
              currency: testBill.currency,
              dateIssued: testBill.dateIssued,
            ),
          );

          // Act
          final result = await localDatasources.createOrUpdateSplitBill(
            updatedBill,
          );

          // Assert
          expect(result, equals('split1'));

          // Verify it was updated
          final savedBill = await localDatasources.getSplitBill('split1');
          expect(savedBill.billEntity.billName, equals('Updated Test Bill'));
        });
      });

      group('getSplitBill', () {
        test('should successfully retrieve an existing split bill', () async {
          // Arrange
          await localDatasources.createOrUpdateSplitBill(testSplitBill);

          // Act
          final result = await localDatasources.getSplitBill('split1');

          // Assert
          expect(result, equals(testSplitBill));
          expect(result.billEntity.billName, equals('Test Bill'));
        });

        test('should throw exception when split bill not found', () async {
          // Act & Assert
          expect(
            () => localDatasources.getSplitBill('nonexistent'),
            throwsA(isA<Exception>()),
          );
        });
      });

      group('deleteBill', () {
        test('should successfully delete a split bill', () async {
          // Arrange
          await localDatasources.createOrUpdateSplitBill(testSplitBill);

          // Act
          await localDatasources.deleteBill('split1');

          // Assert - should not be found
          expect(
            () => localDatasources.getSplitBill('split1'),
            throwsA(isA<Exception>()),
          );
        });
      });
    });

    group('Summary Operations', () {
      late SummaryEntity testSummary;
      late List<UserEntity> testUsers;
      late List<SummaryItemEntity> testSummaryItems;

      setUp(() {
        testUsers = [
          UserEntity(id: 'user1', name: 'John', image: 'image1'),
          UserEntity(id: 'user2', name: 'Jane', image: 'image2'),
        ];

        testSummaryItems = [
          SummaryItemEntity(
            userId: 'user1',
            totalOwned: 25.0,
            items: ['Item 1', 'Item 2'],
          ),
          SummaryItemEntity(
            userId: 'user2',
            totalOwned: 30.0,
            items: ['Item 3'],
          ),
        ];

        testSummary = SummaryEntity(
          id: 'summary1',
          billName: 'Test Bill',
          userList: testUsers,
          summaryList: testSummaryItems,
          currency: '\$',
          dateIssued: '2024-01-01',
        );
      });

      group('createSummary', () {
        test('should successfully create a new summary', () async {
          // Act
          final result = await localDatasources.createSummary(testSummary);

          // Assert
          expect(result, equals('summary1'));

          // Verify it was actually saved
          final savedSummary = await localDatasources.getSummary('summary1');
          expect(savedSummary.id, equals('summary1'));
          expect(savedSummary.billName, equals('Test Bill'));
        });
      });

      group('getSummary', () {
        test('should successfully retrieve an existing summary', () async {
          // Arrange
          await localDatasources.createSummary(testSummary);

          // Act
          final result = await localDatasources.getSummary('summary1');

          // Assert
          expect(result, equals(testSummary));
          expect(result.billName, equals('Test Bill'));
        });

        test('should throw exception when summary not found', () async {
          // Act & Assert
          expect(
            () => localDatasources.getSummary('nonexistent'),
            throwsA(isA<Exception>()),
          );
        });
      });

      group('getAllSummary', () {
        test('should successfully retrieve all summaries', () async {
          // Arrange
          await localDatasources.createSummary(testSummary);

          final secondSummary = SummaryEntity(
            id: 'summary2',
            billName: 'Test Bill 2',
            userList: testUsers,
            summaryList: testSummaryItems,
            currency: '\$',
            dateIssued: '2024-01-02',
          );
          await localDatasources.createSummary(secondSummary);

          // Act
          final result = await localDatasources.getAllSummary();

          // Assert
          expect(result.length, equals(2));
          expect(result.any((s) => s.id == 'summary1'), isTrue);
          expect(result.any((s) => s.id == 'summary2'), isTrue);
        });

        test('should return empty list when no summaries exist', () async {
          // Act
          final result = await localDatasources.getAllSummary();

          // Assert
          expect(result, isEmpty);
        });
      });

      group('deleteSummary', () {
        test('should successfully delete a summary', () async {
          // Arrange
          await localDatasources.createSummary(testSummary);

          // Act
          await localDatasources.deleteSummary('summary1');

          // Assert - should not be found
          expect(
            () => localDatasources.getSummary('summary1'),
            throwsA(isA<Exception>()),
          );
        });
      });
    });

    group('Edge Cases', () {
      test('should handle empty string IDs', () async {
        // Act & Assert
        expect(
          () => localDatasources.getSplitBill(''),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle duplicate IDs (update behavior)', () async {
        // Arrange
        final summary1 = SummaryEntity(
          id: 'duplicate',
          billName: 'First Bill',
          userList: [],
          summaryList: [],
          currency: '\$',
          dateIssued: '2024-01-01',
        );

        final summary2 = SummaryEntity(
          id: 'duplicate',
          billName: 'Second Bill',
          userList: [],
          summaryList: [],
          currency: '\$',
          dateIssued: '2024-01-02',
        );

        // Act
        await localDatasources.createSummary(summary1);
        await localDatasources.createSummary(summary2);

        // Assert - should get the second one (updated)
        final result = await localDatasources.getSummary('duplicate');
        expect(result.billName, equals('Second Bill'));
      });
    });
  });
}
