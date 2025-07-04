import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:split_it/Domain/Models/bill_item_model.dart';
import 'package:split_it/Domain/Usecases/scan_bill_usecase.dart';

part 'scan_page_event.dart';
part 'scan_page_state.dart';

class ScanPageBloc extends Bloc<ScanPageEvent, ScanPageState> {
  final ScanBillUsecase usecase;
  ScanPageBloc({required this.usecase}) : super(ScanPageState()) {
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
      final inputImage = InputImage.fromFile(event.image);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      List<String> allLines = [];
      for (TextBlock block in recognizedText.blocks) {
        allLines.addAll(block.lines.map((e) => e.text));
      }
      final extractedItems = await usecase.getBillItems(allLines);

      emit(
        state.copyWith(
          status: ScanPageStatus.success,
          billItem: extractedItems,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ScanPageStatus.failed, errorMessage: '$e'));
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
          final name = controllers[i * 3].text;
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
        final updatedBillItem = BillItemModel(
          items: items,
          subtotal: subtotal,
          service: service,
          tax: tax,
          discount: discount,
          total: total,
          billName: billName,
        );

        final id = await usecase.saveBill(updatedBillItem);

        emit(state.copyWith(isEdit: false, id: id));

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
