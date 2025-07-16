import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:split_it/Domain/Models/bill_item_model.dart';
import 'package:split_it/Presentation/scan_page/bloc/scan_page_bloc.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  group('ScanPageBloc', () {
    late MockScanBillUsecase mockUsecase;
    late ScanPageBloc bloc;
    late File mockImageFile;
    late MockOCRService mockOCRService;

    setUp(() {
      mockUsecase = MockScanBillUsecase();
      mockOCRService = MockOCRService();
      bloc = ScanPageBloc(usecase: mockUsecase, ocrService: mockOCRService);
      mockImageFile = File('test/assets/valid_bill.jpg');
    });

    tearDown(() {
      bloc.close();
    });

    group('InitScanPage', () {
      test('initial state is correct', () {
        expect(bloc.state.status, equals(ScanPageStatus.initial));
        expect(bloc.state.billItem, isNull);
        expect(bloc.state.errorMessage, isNull);
        expect(bloc.state.isEdit, isFalse);
        expect(bloc.state.controllers, isEmpty);
        expect(bloc.state.id, isEmpty);
      });

      blocTest<ScanPageBloc, ScanPageState>(
        'emits [loading, success] when scan is successful',
        build: () {
          final mockBillItem = BillItemModel(
            items: [
              BillItem(name: 'Test Item 1', quantity: 2, price: 15.0),
              BillItem(name: 'Test Item 2', quantity: 1, price: 10.0),
            ],
            subtotal: 40.0,
            service: 5.0,
            tax: 3.0,
            discount: 2.0,
            total: 46.0,
            billName: 'Test Restaurant Bill',
            currency: '\$',
            dateIssued: '2024-01-15',
          );
          when(mockOCRService.extractLines(mockImageFile)).thenAnswer(
            (_) async => [
              'Test Restaurant Bill',
              'Item: Test Item 1',
              'Quantity: 2',
              'Price: 15.0',
              'Item: Test Item 2',
              'Quantity: 1',
              'Price: 10.0',
              'Subtotal: 40.0',
              'Service: 5.0',
              'Tax: 3.0',
              'Discount: 2.0',
              'Total: 46.0',
            ],
          );
          when(
            mockUsecase.getBillItems(any),
          ).thenAnswer((_) async => mockBillItem);
          return bloc;
        },
        act: (bloc) => bloc.add(InitScanPage(image: mockImageFile)),
        expect: () => [
          isA<ScanPageState>().having(
            (s) => s.status,
            'status',
            ScanPageStatus.loading,
          ),
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.success)
              .having(
                (s) => s.billItem?.billName,
                'bill name',
                'Test Restaurant Bill',
              )
              .having((s) => s.billItem?.items?.length, 'items count', 2)
              .having((s) => s.billItem?.total, 'total amount', 46.0),
        ],
      );

      blocTest<ScanPageBloc, ScanPageState>(
        'emits [loading, failed] when OCR returns empty text',
        build: () {
          when(
            mockOCRService.extractLines(mockImageFile),
          ).thenAnswer((_) async => []);
          when(mockUsecase.getBillItems([])).thenAnswer(
            (_) async => BillItemModel(
              items: [],
              subtotal: 0,
              service: 0,
              tax: 0,
              discount: 0,
              total: 0,
              billName: '',
              currency: '',
              dateIssued: '',
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(InitScanPage(image: mockImageFile)),
        expect: () => [
          isA<ScanPageState>().having(
            (s) => s.status,
            'status',
            ScanPageStatus.loading,
          ),
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.failed)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'No text found in the image. Please make sure you\'re scanning a clear bill or receipt.',
              ),
        ],
      );

      blocTest<ScanPageBloc, ScanPageState>(
        'emits [loading, failed] when text contains no bill keywords',
        build: () {
          when(mockOCRService.extractLines(mockImageFile)).thenAnswer(
            (_) async => ['This is a line with text', 'Another line with text'],
          );
          when(
            mockUsecase.getBillItems(['random text', 'another line']),
          ).thenAnswer(
            (_) async => BillItemModel(
              items: [],
              subtotal: 0,
              service: 0,
              tax: 0,
              discount: 0,
              total: 0,
              billName: '',
              currency: '',
              dateIssued: '',
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(InitScanPage(image: mockImageFile)),
        expect: () => [
          isA<ScanPageState>().having(
            (s) => s.status,
            'status',
            ScanPageStatus.loading,
          ),
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.failed)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'This doesn\'t appear to be a bill or receipt. Please scan a valid bill image.',
              ),
        ],
      );

      blocTest<ScanPageBloc, ScanPageState>(
        'emits [loading, failed] when no bill items are extracted',
        build: () {
          when(mockOCRService.extractLines(mockImageFile)).thenAnswer(
            (_) async => [
              'Item: Test Item 1',
              'Quantity: 2',
              'Price: 15.0',
              'Item: Test Item 2',
              'Quantity: 1',
              'Price: 10.0',
              'Subtotal: 40.0',
              'Service: 5.0',
              'Tax: 3.0',
              'Discount: 2.0',
              'Total: 46.0',
            ],
          );
          when(mockUsecase.getBillItems(any)).thenAnswer(
            (_) async => BillItemModel(
              items: [], // Empty items
              subtotal: 10.0,
              service: 0.0,
              tax: 0.0,
              discount: 0.0,
              total: 10.0,
              billName: 'Test Bill',
              currency: '\$',
              dateIssued: '2024-01-01',
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(InitScanPage(image: mockImageFile)),
        expect: () => [
          isA<ScanPageState>().having(
            (s) => s.status,
            'status',
            ScanPageStatus.loading,
          ),
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.failed)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Could not extract bill items from the image. Please try with a clearer image.',
              ),
        ],
      );

      blocTest<ScanPageBloc, ScanPageState>(
        'emits [loading, failed] when total amount is invalid',
        build: () {
          when(mockOCRService.extractLines(mockImageFile)).thenAnswer(
            (_) async => [
              'Item: Test Item',
              'Quantity: 1',
              'Price: 10.0',
              'Subtotal: 10.0',
              'Service: 0.0',
              'Tax: 0.0',
              'Discount: 0.0',
              'Total: 0', // Invalid total
            ],
          );
          when(mockUsecase.getBillItems(any)).thenAnswer(
            (_) async => BillItemModel(
              items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
              subtotal: 10.0,
              service: 0.0,
              tax: 0.0,
              discount: 0.0,
              total: 0, // Invalid total
              billName: 'Test Bill',
              currency: '\$',
              dateIssued: '2024-01-01',
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(InitScanPage(image: mockImageFile)),
        expect: () => [
          isA<ScanPageState>().having(
            (s) => s.status,
            'status',
            ScanPageStatus.loading,
          ),
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.failed)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Could not detect a valid total amount. Please ensure the total is clearly visible in the image.',
              ),
        ],
      );

      blocTest<ScanPageBloc, ScanPageState>(
        'emits [loading, failed] when network error occurs',
        build: () {
          when(mockOCRService.extractLines(mockImageFile)).thenThrow(
            Exception('Failed to connect to DeepSeek API: Connection timeout'),
          );
          when(mockUsecase.getBillItems(any)).thenAnswer(
            (_) async => BillItemModel(
              items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
              subtotal: 10.0,
              service: 0.0,
              tax: 0.0,
              discount: 0.0,
              total: 10.0,
              billName: 'Test Bill',
              currency: '\$',
              dateIssued: '2024-01-01',
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(InitScanPage(image: mockImageFile)),
        expect: () => [
          isA<ScanPageState>().having(
            (s) => s.status,
            'status',
            ScanPageStatus.loading,
          ),
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.failed)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Network error. Please check your internet connection and try again.',
              ),
        ],
      );

      blocTest<ScanPageBloc, ScanPageState>(
        'emits [loading, failed] when JSON parsing fails',
        build: () {
          when(
            mockOCRService.extractLines(mockImageFile),
          ).thenAnswer((_) async => ["any", 'text', 'total']);
          when(
            mockUsecase.getBillItems(any),
          ).thenThrow(Exception("Invalid JSON returned"));
          return bloc;
        },
        act: (bloc) => bloc.add(InitScanPage(image: mockImageFile)),
        expect: () => [
          isA<ScanPageState>().having(
            (s) => s.status,
            'status',
            ScanPageStatus.loading,
          ),
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.failed)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Could not process the bill data. Please try with a clearer image.',
              ),
        ],
      );

      blocTest<ScanPageBloc, ScanPageState>(
        'emits [loading, failed] when general exception occurs',
        build: () {
          when(
            mockOCRService.extractLines(mockImageFile),
          ).thenThrow(Exception('Unknown error occurred'));
          when(mockUsecase.getBillItems(any)).thenAnswer(
            (_) async => BillItemModel(
              items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
              subtotal: 10.0,
              service: 0.0,
              tax: 0.0,
              discount: 0.0,
              total: 10.0,
              billName: 'Test Bill',
              currency: '\$',
              dateIssued: '2024-01-01',
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(InitScanPage(image: mockImageFile)),
        expect: () => [
          isA<ScanPageState>().having(
            (s) => s.status,
            'status',
            ScanPageStatus.loading,
          ),
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.failed)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Unable to process this image. Please ensure it\'s a clear photo of a bill or receipt.',
              ),
        ],
      );
    });

    group('EditScanPage', () {
      blocTest<ScanPageBloc, ScanPageState>(
        'emits [isEdit: true] when edit mode is activated',
        build: () {
          // Set initial state with bill data
          bloc.emit(
            bloc.state.copyWith(
              status: ScanPageStatus.success,
              billItem: BillItemModel(
                items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
                subtotal: 10.0,
                service: 0.0,
                tax: 0.0,
                discount: 0.0,
                total: 10.0,
                billName: 'Test Bill',
                currency: '\$',
                dateIssued: '2024-01-01',
              ),
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(EditScanPage()),
        expect: () => [
          isA<ScanPageState>()
              .having((s) => s.isEdit, 'isEdit', true)
              .having(
                (s) => s.controllers.length,
                'controllers length',
                8,
              ), // 3 for item + 5 for totals
        ],
      );

      blocTest<ScanPageBloc, ScanPageState>(
        'populates controllers with correct values when entering edit mode',
        build: () {
          final billItem = BillItemModel(
            items: [
              BillItem(name: 'Item 1', quantity: 2, price: 15.0),
              BillItem(name: 'Item 2', quantity: 1, price: 10.0),
            ],
            subtotal: 40.0,
            service: 5.0,
            tax: 3.0,
            discount: 2.0,
            total: 46.0,
            billName: 'Test Bill',
            currency: '\$',
            dateIssued: '2024-01-01',
          );

          bloc.emit(
            bloc.state.copyWith(
              status: ScanPageStatus.success,
              billItem: billItem,
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(EditScanPage()),
        expect: () => [
          isA<ScanPageState>()
              .having((s) => s.isEdit, 'isEdit', true)
              .having(
                (s) => s.controllers.length,
                'controllers length',
                11,
              ), // 6 for items + 5 for totals
        ],
      );

      blocTest<ScanPageBloc, ScanPageState>(
        'does not change state when already in edit mode',
        build: () {
          bloc.emit(
            bloc.state.copyWith(
              status: ScanPageStatus.success,
              isEdit: true,
              billItem: BillItemModel(
                items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
                subtotal: 10.0,
                service: 0.0,
                tax: 0.0,
                discount: 0.0,
                total: 10.0,
                billName: 'Test Bill',
                currency: '\$',
                dateIssued: '2024-01-01',
              ),
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(EditScanPage()),
        expect: () => [], // No state changes expected
      );
    });

    group('EditScanPageDispose', () {
      blocTest<ScanPageBloc, ScanPageState>(
        'emits [finish] when save is successful in non-edit mode',
        build: () {
          when(
            mockUsecase.saveBill(any),
          ).thenAnswer((_) async => 'test-bill-id');

          bloc.emit(
            bloc.state.copyWith(
              status: ScanPageStatus.success,
              billItem: BillItemModel(
                items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
                subtotal: 10.0,
                service: 0.0,
                tax: 0.0,
                discount: 0.0,
                total: 10.0,
                billName: 'Test Bill',
                currency: '\$',
                dateIssued: '2024-01-01',
              ),
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(EditScanPageDispose()),
        expect: () => [
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.success)
              .having((s) => s.id, 'id', 'test-bill-id'),
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.finish)
              .having((s) => s.id, 'id', 'test-bill-id'),
        ],
      );

      blocTest<ScanPageBloc, ScanPageState>(
        'emits [finish] when save is successful in edit mode',
        build: () {
          when(
            mockUsecase.saveBill(any),
          ).thenAnswer((_) async => 'test-bill-id');

          final controllers = List.generate(
            8,
            (index) => TextEditingController(),
          );
          // Set some test values
          controllers[0].text = 'Updated Item';
          controllers[1].text = '2';
          controllers[2].text = '20.0';
          controllers[3].text = '40.0'; // subtotal
          controllers[4].text = '5.0'; // service
          controllers[5].text = '3.0'; // tax
          controllers[6].text = '2.0'; // discount
          controllers[7].text = '46.0'; // total

          bloc.emit(
            bloc.state.copyWith(
              status: ScanPageStatus.success,
              isEdit: true,
              controllers: controllers,
              billItem: BillItemModel(
                items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
                subtotal: 10.0,
                service: 0.0,
                tax: 0.0,
                discount: 0.0,
                total: 10.0,
                billName: 'Test Bill',
                currency: '\$',
                dateIssued: '2024-01-01',
              ),
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(EditScanPageDispose()),
        expect: () => [
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.success)
              .having((s) => s.id, 'id', 'test-bill-id'),
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.finish)
              .having((s) => s.id, 'id', 'test-bill-id')
              .having((s) => s.isEdit, 'isEdit', false)
              .having(
                (s) => s.controllers[0].text,
                'item name',
                'Updated Item',
              ),
        ],
      );

      blocTest<ScanPageBloc, ScanPageState>(
        'emits [failed] when save fails in non-edit mode',
        build: () {
          when(
            mockUsecase.saveBill(any),
          ).thenThrow(Exception('Database error'));

          bloc.emit(
            bloc.state.copyWith(
              status: ScanPageStatus.success,
              billItem: BillItemModel(
                items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
                subtotal: 10.0,
                service: 0.0,
                tax: 0.0,
                discount: 0.0,
                total: 10.0,
                billName: 'Test Bill',
                currency: '\$',
                dateIssued: '2024-01-01',
              ),
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(EditScanPageDispose()),
        expect: () => [
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.failed)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Exception: Database error',
              ),
        ],
      );

      blocTest<ScanPageBloc, ScanPageState>(
        'emits [failed] when save fails in edit mode',
        build: () {
          when(
            mockUsecase.saveBill(any),
          ).thenThrow(Exception('Validation error'));

          final controllers = List.generate(
            8,
            (index) => TextEditingController(),
          );
          bloc.emit(
            bloc.state.copyWith(
              status: ScanPageStatus.success,
              isEdit: true,
              controllers: controllers,
              billItem: BillItemModel(
                items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
                subtotal: 10.0,
                service: 0.0,
                tax: 0.0,
                discount: 0.0,
                total: 10.0,
                billName: 'Test Bill',
                currency: '\$',
                dateIssued: '2024-01-01',
              ),
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(EditScanPageDispose()),
        expect: () => [
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.failed)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Exception: Validation error',
              ),
        ],
      );

      blocTest<ScanPageBloc, ScanPageState>(
        'test invalid controller data',
        build: () {
          when(mockUsecase.saveBill(any)).thenAnswer((_) async => 'test-id');

          final controllers = List.generate(
            8,
            (index) => TextEditingController(),
          );
          // Set invalid values
          controllers[0].text = ''; // empty name
          controllers[1].text = 'invalid'; // invalid quantity
          controllers[2].text = 'invalid'; // invalid price
          controllers[3].text = 'invalid'; // invalid subtotal
          controllers[4].text = 'invalid'; // invalid service
          controllers[5].text = 'invalid'; // invalid tax
          controllers[6].text = 'invalid'; // invalid discount
          controllers[7].text = 'invalid'; // invalid total

          bloc.emit(
            bloc.state.copyWith(
              status: ScanPageStatus.success,
              isEdit: true,
              controllers: controllers,
              billItem: BillItemModel(
                items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
                subtotal: 10.0,
                service: 0.0,
                tax: 0.0,
                discount: 0.0,
                total: 10.0,
                billName: 'Test Bill',
                currency: '\$',
                dateIssued: '2024-01-01',
              ),
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(EditScanPageDispose()),
        expect: () => [
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.success)
              .having((s) => s.id, 'id', 'test-id'),
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.finish)
              .having((s) => s.id, 'id', 'test-id')
              .having((s) => s.billItem?.items?[0].name, 'bill name', 'SplitIt')
              .having((s) => s.billItem?.total, 'updated total', 0),
        ],
      );
    });

    group('State Management', () {
      test('copyWith creates new state with updated values', () {
        final initialState = ScanPageState();
        final updatedState = initialState.copyWith(
          status: ScanPageStatus.success,
          billItem: BillItemModel(
            items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
            subtotal: 10.0,
            service: 0.0,
            tax: 0.0,
            discount: 0.0,
            total: 10.0,
            billName: 'Test Bill',
            currency: '\$',
            dateIssued: '2024-01-01',
          ),
          isEdit: true,
          errorMessage: 'Test error',
          id: 'test-id',
        );

        expect(updatedState.status, equals(ScanPageStatus.success));
        expect(updatedState.billItem?.billName, equals('Test Bill'));
        expect(updatedState.isEdit, isTrue);
        expect(updatedState.errorMessage, equals('Test error'));
        expect(updatedState.id, equals('test-id'));
        expect(updatedState, isNot(same(initialState)));
      });

      test('copyWith preserves existing values when not specified', () {
        final initialState = ScanPageState(
          status: ScanPageStatus.success,
          billItem: BillItemModel(
            items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
            subtotal: 10.0,
            service: 0.0,
            tax: 0.0,
            discount: 0.0,
            total: 10.0,
            billName: 'Test Bill',
            currency: '\$',
            dateIssued: '2024-01-01',
          ),
          isEdit: true,
          errorMessage: 'Test error',
          id: 'test-id',
        );

        final updatedState = initialState.copyWith(
          status: ScanPageStatus.finish,
        );

        expect(updatedState.status, equals(ScanPageStatus.finish));
        expect(updatedState.billItem, equals(initialState.billItem));
        expect(updatedState.isEdit, equals(initialState.isEdit));
        expect(updatedState.errorMessage, equals(initialState.errorMessage));
        expect(updatedState.id, equals(initialState.id));
      });

      test('state props contain all relevant fields', () {
        final state = ScanPageState(
          status: ScanPageStatus.success,
          billItem: BillItemModel(
            items: [BillItem(name: 'Test Item', quantity: 1, price: 10.0)],
            subtotal: 10.0,
            service: 0.0,
            tax: 0.0,
            discount: 0.0,
            total: 10.0,
            billName: 'Test Bill',
            currency: '\$',
            dateIssued: '2024-01-01',
          ),
          isEdit: true,
          errorMessage: 'Test error',
          id: 'test-id',
        );

        expect(
          state.props,
          containsAll([
            ScanPageStatus.success,
            state.billItem,
            true,
            'Test error',
            'test-id',
          ]),
        );
      });
    });

    group('Integration Tests', () {
      blocTest<ScanPageBloc, ScanPageState>(
        'handles complete scan workflow successfully',
        build: () {
          final mockBillItem = BillItemModel(
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

          when(mockOCRService.extractLines(mockImageFile)).thenAnswer(
            (_) async => [
              'Test Restaurant Bill',
              'Item: Test Item 1',
              'Quantity: 2',
              'Price: 15.0',
              'Item: Test Item 2',
              'Quantity: 1',
              'Price: 10.0',
              'Subtotal: 40.0',
              'Service: 5.0',
              'Tax: 3.0',
              'Discount: 2.0',
              'Total: 46.0',
            ],
          );
          when(
            mockUsecase.getBillItems(any),
          ).thenAnswer((_) async => mockBillItem);
          when(
            mockUsecase.saveBill(any),
          ).thenAnswer((_) async => 'test-bill-id');
          return bloc;
        },
        act: (bloc) async {
          bloc.add(InitScanPage(image: mockImageFile));
          await Future.delayed(Duration(milliseconds: 100));
          bloc.add(EditScanPage());
          await Future.delayed(Duration(milliseconds: 100));
          bloc.add(EditScanPageDispose());
        },
        expect: () => [
          isA<ScanPageState>().having(
            (s) => s.status,
            'status',
            ScanPageStatus.loading,
          ),
          isA<ScanPageState>().having(
            (s) => s.status,
            'status',
            ScanPageStatus.success,
          ),
          isA<ScanPageState>().having((s) => s.isEdit, 'isEdit', true),
          isA<ScanPageState>().having((s) => s.isEdit, 'isEdit', false),
          isA<ScanPageState>()
              .having((s) => s.status, 'status', ScanPageStatus.finish)
              .having((s) => s.isEdit, 'isEdit', false),
        ],
      );
    });
  });
}
