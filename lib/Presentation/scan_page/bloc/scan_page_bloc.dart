import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:split_it/Domain/Models/BillItemModel.dart';
import 'package:split_it/Domain/Usecases/scan_bill_usecase.dart';

part 'scan_page_event.dart';
part 'scan_page_state.dart';

class ScanPageBloc extends Bloc<ScanPageEvent, ScanPageState> {
  final ScanBillUsecase usecase;
  ScanPageBloc({required this.usecase}) : super(ScanPageState()) {
    on<InitScanPage>(_initScanPage);
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
}
