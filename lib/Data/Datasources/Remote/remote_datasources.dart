import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:split_it/Data/Datasources/Remote/Responses/deepseek_response.dart';
import 'package:split_it/Data/Datasources/Remote/network/dio.dart';

class RemoteDatasources {
  final NetworkCall networkCall;
  RemoteDatasources({required this.networkCall});

  Future<DeepseekResponse> cleanOCRText(List<String> rawOcr) async {
    final payload = {
      "model": "google/gemma-3-12b-it:free",
      "messages": [
        {
          "role": "user",
          "content":
              "This is a receipt OCR result. Extract and return a JSON with:\n"
              "- bill name\n"
              "- list of items (name, quantity, price (make sure the price is the total price and not unit price, if it is a unit price, multiply it with the quantity))\n"
              "- subtotal, service, tax, discount and total\n"
              "- the currency used (if not mentioned return the currency based on the language, if its still unrecognisable use \$)\n"
              "- date issued\n\n"
              "Receipt:\n$rawOcr",
        },
      ],
    };

    try {
      final response = await GetIt.I<NetworkCall>().post(
        '',
        data: jsonEncode(payload),
      );

      final message = response.data['choices'][0]['message']['content'];

      // Remove markdown code block markers if present
      final cleanedMessage = message
          .replaceAll(RegExp(r'^```json', multiLine: true), '')
          .replaceAll(RegExp(r'^```', multiLine: true), '')
          .replaceAll(RegExp(r'```$', multiLine: true), '')
          .trim();

      final result = DeepseekResponse.fromJson(jsonDecode(cleanedMessage));

      // Validate the response contains meaningful bill data
      if (result.items == null || result.items!.isEmpty) {
        throw Exception("No bill items found in the image");
      }

      if (result.total == null || result.total! <= 0) {
        throw Exception("No valid total amount found in the image");
      }

      return result;
    } on DioException catch (e) {
      throw Exception(
        "Failed to connect to DeepSeek API: \\${e.response?.data}",
      );
    } catch (e) {
      if (e.toString().contains("No bill items found") ||
          e.toString().contains("No valid total amount")) {
        throw Exception("Invalid bill image: $e");
      }
      throw Exception("Invalid JSON returned: $e");
    }
  }
}
