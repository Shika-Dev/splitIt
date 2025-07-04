import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:split_it/Data/Datasources/Remote/Responses/deepseek_response.dart';

class RemoteDatasources {
  Future<DeepseekResponse> cleanOCRText(List<String> rawOcr) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    const url = 'https://openrouter.ai/api/v1/chat/completions';

    final dio = Dio(
      BaseOptions(
        baseUrl: url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
    );
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
      final response = await dio.post('', data: jsonEncode(payload));

      final message = response.data['choices'][0]['message']['content'];

      // Remove markdown code block markers if present
      final cleanedMessage = message
          .replaceAll(RegExp(r'^```json', multiLine: true), '')
          .replaceAll(RegExp(r'^```', multiLine: true), '')
          .replaceAll(RegExp(r'```$', multiLine: true), '')
          .trim();

      final result = DeepseekResponse.fromJson(jsonDecode(cleanedMessage));
      return result;
    } on DioException catch (e) {
      throw Exception("Failed to connect to DeepSeek API: ${e.response?.data}");
    } catch (e) {
      throw Exception("Invalid JSON returned: $e");
    }
  }
}
