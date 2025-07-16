import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:split_it/Domain/Models/bill_item_model.dart';
import 'package:split_it/Domain/Usecases/scan_bill_usecase.dart';
import 'package:split_it/Core/Services/ocr_service.dart';

part 'scan_page_event.dart';
part 'scan_page_state.dart';

class ScanPageBloc extends Bloc<ScanPageEvent, ScanPageState> {
  final ScanBillUsecase usecase;
  final OCRService ocrService;
  ScanPageBloc({required this.usecase, required this.ocrService})
    : super(ScanPageState()) {
    on<InitScanPage>(_initScanPage);
    on<EditScanPage>(_editScanPage);
    on<EditScanPageDispose>(_editScanPageDispose);
  }

  Future<void> _initScanPage(
    InitScanPage event,
    Emitter<ScanPageState> emit,
  ) async {
    emit(state.copyWith(status: ScanPageStatus.loading));
    try {
      final allLines = await ocrService.extractLines(event.image);

      // Check if OCR extracted any meaningful text
      if (allLines.isEmpty) {
        emit(
          state.copyWith(
            status: ScanPageStatus.failed,
            errorMessage:
                'No text found in the image. Please make sure you\'re scanning a clear bill or receipt.',
          ),
        );
        return;
      }

      // Check if the text contains bill-related keywords
      final billKeywords = [
        'total',
        'subtotal',
        'tax',
        'receipt',
        'bill',
        'amount',
        'price',
        'item',
        'quantity',
      ];
      final hasBillContent = allLines.any(
        (line) =>
            billKeywords.any((keyword) => line.toLowerCase().contains(keyword)),
      );

      if (!hasBillContent) {
        emit(
          state.copyWith(
            status: ScanPageStatus.failed,
            errorMessage:
                'This doesn\'t appear to be a bill or receipt. Please scan a valid bill image.',
          ),
        );
        return;
      }

      final extractedItems = await usecase.getBillItems(allLines);

      // Validate that we got meaningful bill data
      if (extractedItems.items == null || extractedItems.items!.isEmpty) {
        emit(
          state.copyWith(
            status: ScanPageStatus.failed,
            errorMessage:
                'Could not extract bill items from the image. Please try with a clearer image.',
          ),
        );
        return;
      }

      if (extractedItems.total <= 0) {
        emit(
          state.copyWith(
            status: ScanPageStatus.failed,
            errorMessage:
                'Could not detect a valid total amount. Please ensure the total is clearly visible in the image.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: ScanPageStatus.success,
          billItem: extractedItems,
        ),
      );
    } catch (e) {
      String errorMessage = 'An error occurred while processing the image.';

      // Provide more specific error messages based on the exception
      if (e.toString().contains('Failed to connect to DeepSeek API')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('Invalid JSON')) {
        errorMessage =
            'Could not process the bill data. Please try with a clearer image.';
      } else if (e.toString().contains('Exception')) {
        errorMessage =
            'Unable to process this image. Please ensure it\'s a clear photo of a bill or receipt.';
      }

      emit(
        state.copyWith(
          status: ScanPageStatus.failed,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  Future<void> _editScanPage(
    EditScanPage event,
    Emitter<ScanPageState> emit,
  ) async {
    if (!state.isEdit) {
      List<TextEditingController> listController = List.generate(
        (state.billItem?.items?.length ?? 0) * 3 + 5,
        (index) => TextEditingController(),
      );
      var index = 0;
      state.billItem?.items?.forEach((element) {
        listController[index].text = element.name;
        listController[index + 1].text = element.quantity.toString();
        listController[index + 2].text = element.price.toString();
        index += 3;
      });
      listController[index].text = state.billItem?.subtotal.toString() ?? '0';
      listController[index + 1].text =
          state.billItem?.service.toString() ?? '0';
      listController[index + 2].text = state.billItem?.tax.toString() ?? '0';
      listController[index + 3].text =
          state.billItem?.discount.toString() ?? '0';
      listController[index + 4].text = state.billItem?.total.toString() ?? '0';

      emit(state.copyWith(isEdit: true, controllers: listController));
    }
  }

  Future<void> _editScanPageDispose(
    EditScanPageDispose event,
    Emitter<ScanPageState> emit,
  ) async {
    // Reconstruct BillItemModel from controllers
    try {
      if (state.isEdit) {
        final controllers = state.controllers;
        final items = <BillItem>[];
        int itemCount = (controllers.length - 5) ~/ 3;
        for (int i = 0; i < itemCount; i++) {
          final name = controllers[i * 3].text.isNotEmpty
              ? controllers[i * 3].text
              : 'SplitIt';
          final quantity = num.tryParse(controllers[i * 3 + 1].text) ?? 0;
          final price = num.tryParse(controllers[i * 3 + 2].text) ?? 0;
          items.add(BillItem(name: name, quantity: quantity, price: price));
        }
        final subtotal = num.tryParse(controllers[itemCount * 3].text) ?? 0;
        final service = num.tryParse(controllers[itemCount * 3 + 1].text) ?? 0;
        final tax = num.tryParse(controllers[itemCount * 3 + 2].text) ?? 0;
        final discount = num.tryParse(controllers[itemCount * 3 + 3].text) ?? 0;
        final total = num.tryParse(controllers[itemCount * 3 + 4].text) ?? 0;
        final billName = state.billItem?.billName ?? '';
        final currency = state.billItem?.currency ?? '';
        final dateIssued = state.billItem?.dateIssued ?? '';
        final updatedBillItem = BillItemModel(
          items: items,
          subtotal: subtotal,
          service: service,
          tax: tax,
          discount: discount,
          total: total,
          billName: billName,
          currency: currency,
          dateIssued: dateIssued,
        );

        final id = await usecase.saveBill(updatedBillItem);

        emit(state.copyWith(isEdit: false, id: id, billItem: updatedBillItem));

        for (var element in state.controllers) {
          element.dispose();
        }
      } else {
        final id = await usecase.saveBill(state.billItem!);

        emit(state.copyWith(id: id));
      }

      emit(state.copyWith(status: ScanPageStatus.finish));
    } on Exception catch (e) {
      emit(state.copyWith(status: ScanPageStatus.failed, errorMessage: '$e'));
    }
  }
}
