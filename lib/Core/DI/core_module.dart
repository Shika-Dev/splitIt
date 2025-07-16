import 'package:get_it/get_it.dart';
import 'package:split_it/Core/Services/ocr_service.dart';

class CoreModule {
  static void provide() {
    GetIt getIt = GetIt.instance;
    getIt.registerSingleton<OCRService>(MLOCRService());
  }
}
