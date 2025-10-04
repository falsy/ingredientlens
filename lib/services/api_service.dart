import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

const String stage = 'v4'; // API 버전

class ApiService {
  static String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL not found in environment variables');
    }
    return url;
  }

  static const Duration _timeout = Duration(seconds: 30);

  static Future<Map<String, dynamic>> analyzeIngredients({
    required File imageFile,
    required String category,
    required String langCode,
    Map<String, List<String>>? profile,
    Map<String, List<String>>? baby,
    Map<String, List<String>>? pet,
  }) async {
    try {
      // 이미지 리사이즈
      final resizedImage = await _resizeImage(imageFile);

      // Create multipart request
      final uri = Uri.parse('$_baseUrl/analyzeIngredients');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['x-api-version'] = stage;

      // Add fields
      request.fields['category'] = category;
      request.fields['langCode'] = langCode;

      // Add preference data based on user selection (not category)
      if (profile != null && profile.isNotEmpty) {
        request.fields['profile'] = json.encode(profile);
      }
      if (baby != null && baby.isNotEmpty) {
        request.fields['baby'] = json.encode(baby);
      }
      if (pet != null && pet.isNotEmpty) {
        request.fields['pet'] = json.encode(pet);
      }

      // Add image file
      final imageBytes = await resizedImage.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'ingredients',
        imageBytes,
        filename: 'ingredients.jpg',
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      // Clean up temp file
      try {
        await resizedImage.delete();
      } catch (_) {}

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(
              '✅ [API SUCCESS] analyzeIngredients - Status: ${response.statusCode}');
        }
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        if (kDebugMode) {
          print('📋 [API RESPONSE] analyzeIngredients JSON:');
          const encoder = JsonEncoder.withIndent('  ');
          print(encoder.convert(jsonData));
        }
        return jsonData;
      } else {
        if (kDebugMode) {
          print(
              '❌ [API ERROR] analyzeIngredients - Status: ${response.statusCode}');
          print('📝 Response Body: ${response.body}');
        }

        // Vision API 에러 확인
        if (response.statusCode == 500) {
          try {
            final errorData = json.decode(utf8.decode(response.bodyBytes));
            if (kDebugMode) {
              print(
                  '🔍 [API 500 ERROR] analyzeIngredients - JSON Response: $errorData');
            }
            if (errorData['error'] == 'Vision API error') {
              throw Exception('VISION_API_ERROR');
            }
          } catch (e) {
            // JSON 파싱 실패 시에도 Vision API 에러인지 확인
            if (kDebugMode) {
              print('🔍 [API] Error parsing response: $e');
            }
            // Response Body에서 직접 문자열 확인
            if (response.body.contains('Vision API error')) {
              throw Exception('VISION_API_ERROR');
            }
          }
        }

        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('💥 [API EXCEPTION] analyzeIngredients - Error: $e');
      }
      throw Exception('Failed to analyze ingredients: $e');
    }
  }

  static Future<List<dynamic>> analyzeCalorie({
    required File imageFile,
    required String langCode,
  }) async {
    try {
      // 이미지 리사이즈
      final resizedImage = await _resizeImage(imageFile);

      // Create multipart request
      final uri = Uri.parse('$_baseUrl/analyzeCalorie');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['x-api-version'] = stage;

      // Add fields
      request.fields['langCode'] = langCode;

      // Add image file with 'food' field name
      final imageBytes = await resizedImage.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'food',
        imageBytes,
        filename: 'food.jpg',
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      // Clean up temp file
      try {
        await resizedImage.delete();
      } catch (_) {}

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(
              '✅ [API SUCCESS] analyzeCalorie - Status: ${response.statusCode}');
        }
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        if (kDebugMode) {
          print('📋 [API RESPONSE] analyzeCalorie JSON:');
          const encoder = JsonEncoder.withIndent('  ');
          print(encoder.convert(jsonData));
        }

        // error 필드 확인
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('error')) {
          final errorMessage = jsonData['error'];
          if (errorMessage == 'Food information not found') {
            throw Exception('FOOD_NOT_FOUND');
          }
          throw Exception('API_ERROR: $errorMessage');
        }

        // 응답이 Map 형태인 경우 foods 배열 반환
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('foods')) {
          return jsonData['foods'] as List<dynamic>;
        }

        throw Exception('Unexpected response format');
      } else {
        if (kDebugMode) {
          print(
              '❌ [API ERROR] analyzeCalorie - Status: ${response.statusCode}');
          print('📝 Response Body: ${response.body}');
        }

        // Vision API 에러 확인
        if (response.statusCode == 500) {
          try {
            final errorData = json.decode(utf8.decode(response.bodyBytes));
            if (kDebugMode) {
              print(
                  '🔍 [API 500 ERROR] analyzeCalorie - JSON Response: $errorData');
            }
          } catch (e) {
            if (kDebugMode) {
              print('🔍 [API] Error parsing response: $e');
            }
          }
        }

        throw Exception('analyzeCalorie API request failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [API EXCEPTION] analyzeCalorie Error: $e');
      }
      throw Exception('analyzeCalorie API request failed: $e');
    }
  }

  static Future<Map<String, dynamic>> analyzeNutrition({
    required File imageFile,
    required String category,
    required String langCode,
    Map<String, List<String>>? profile,
    Map<String, List<String>>? baby,
    Map<String, List<String>>? pet,
  }) async {
    try {
      // 이미지 리사이즈
      final resizedImage = await _resizeImage(imageFile);

      // Create multipart request
      final uri = Uri.parse('$_baseUrl/analyzeNutrition');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['x-api-version'] = stage;

      // Add fields
      request.fields['category'] = category;
      request.fields['langCode'] = langCode;

      // Add preference data based on user selection
      if (profile != null && profile.isNotEmpty) {
        request.fields['profile'] = json.encode(profile);
      }
      if (baby != null && baby.isNotEmpty) {
        request.fields['baby'] = json.encode(baby);
      }
      if (pet != null && pet.isNotEmpty) {
        request.fields['pet'] = json.encode(pet);
      }

      // Add image file with 'nutrition' field name
      final imageBytes = await resizedImage.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'nutrition',
        imageBytes,
        filename: 'nutrition.jpg',
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      // Clean up temp file
      try {
        await resizedImage.delete();
      } catch (_) {}

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(
              '✅ [API SUCCESS] analyzeNutrition - Status: ${response.statusCode}');
        }
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        if (kDebugMode) {
          print('📋 [API RESPONSE] analyzeNutrition JSON:');
          const encoder = JsonEncoder.withIndent('  ');
          print(encoder.convert(jsonData));
        }

        // error 필드 확인
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('error')) {
          final errorMessage = jsonData['error'];
          if (errorMessage == 'Nutritional information not found') {
            throw Exception('NUTRITION_NOT_FOUND');
          }
          throw Exception('API_ERROR: $errorMessage');
        }

        return jsonData;
      } else {
        if (kDebugMode) {
          print(
              '❌ [API ERROR] analyzeNutrition - Status: ${response.statusCode}');
          print('📝 Response Body: ${response.body}');
        }

        // Vision API 에러 확인
        if (response.statusCode == 500) {
          try {
            final errorData = json.decode(utf8.decode(response.bodyBytes));
            if (kDebugMode) {
              print(
                  '🔍 [API 500 ERROR] analyzeNutrition - JSON Response: $errorData');
            }
          } catch (e) {
            // JSON 파싱 실패 시에도 Vision API 에러인지 확인
            if (kDebugMode) {
              print('🔍 [API] Error parsing response: $e');
            }
          }
        }

        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('💥 [API EXCEPTION] analyzeNutrition - Error: $e');
      }
      throw Exception('Failed to analyze nutrition: $e');
    }
  }

  static Future<Map<String, dynamic>> compareIngredients({
    required File imageA,
    required File imageB,
    required String category,
    required String langCode,
    Map<String, List<String>>? profile,
    Map<String, List<String>>? baby,
    Map<String, List<String>>? pet,
  }) async {
    try {
      // 이미지 리사이즈
      final resizedImageA = await _resizeImage(imageA);
      final resizedImageB = await _resizeImage(imageB);

      // Create multipart request
      final uri = Uri.parse('$_baseUrl/compareIngredients');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['x-api-version'] = stage;

      // Add fields
      request.fields['category'] = category;
      request.fields['langCode'] = langCode;

      // Add preference data based on user selection (not category)
      if (profile != null && profile.isNotEmpty) {
        request.fields['profile'] = json.encode(profile);
      }
      if (baby != null && baby.isNotEmpty) {
        request.fields['baby'] = json.encode(baby);
      }
      if (pet != null && pet.isNotEmpty) {
        request.fields['pet'] = json.encode(pet);
      }

      // Add image files
      final imageBytesA = await resizedImageA.readAsBytes();
      final multipartFileA = http.MultipartFile.fromBytes(
        'imageA',
        imageBytesA,
        filename: 'product_a.jpg',
      );
      request.files.add(multipartFileA);

      final imageBytesB = await resizedImageB.readAsBytes();
      final multipartFileB = http.MultipartFile.fromBytes(
        'imageB',
        imageBytesB,
        filename: 'product_b.jpg',
      );
      request.files.add(multipartFileB);

      // Send request
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      // Clean up temp files
      try {
        await resizedImageA.delete();
        await resizedImageB.delete();
      } catch (_) {}

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(
              '✅ [API SUCCESS] compareIngredients - Status: ${response.statusCode}');
        }
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        if (kDebugMode) {
          print('📋 [API RESPONSE] compareIngredients JSON:');
          const encoder = JsonEncoder.withIndent('  ');
          print(encoder.convert(jsonData));
        }
        return jsonData;
      } else {
        if (kDebugMode) {
          print(
              '❌ [API ERROR] compareIngredients - Status: ${response.statusCode}');
          print('📝 Response Body: ${response.body}');
        }

        // Vision API 에러 확인
        if (response.statusCode == 500) {
          try {
            final errorData = json.decode(utf8.decode(response.bodyBytes));
            if (kDebugMode) {
              print(
                  '🔍 [API 500 ERROR] compareIngredients - JSON Response: $errorData');
            }
            if (errorData['error'] == 'Vision API error') {
              throw Exception('VISION_API_ERROR');
            }
          } catch (e) {
            // JSON 파싱 실패 시에도 Vision API 에러인지 확인
            if (kDebugMode) {
              print('🔍 [API] Error parsing response: $e');
            }
            // Response Body에서 직접 문자열 확인
            if (response.body.contains('Vision API error')) {
              throw Exception('VISION_API_ERROR');
            }
          }
        }

        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('💥 [API EXCEPTION] compareIngredients - Error: $e');
      }
      throw Exception('Failed to compare ingredients: $e');
    }
  }

  static Future<Map<String, dynamic>> getIngredientDetail({
    required String ingredient,
    required String category,
    required String langCode,
    Map<String, List<String>>? profile,
    Map<String, List<String>>? baby,
    Map<String, List<String>>? pet,
  }) async {
    try {
      final uri = Uri.parse(
          'https://us-central1-ingredient-lens-463212.cloudfunctions.net/ingredientDetail');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-api-version': stage,
            },
            body: json.encode({
              'ingredient': ingredient,
              'category': category,
              'langCode': langCode,
              if (profile != null && profile.isNotEmpty)
                'profile': json.encode(profile),
              if (baby != null && baby.isNotEmpty) 'baby': json.encode(baby),
              if (pet != null && pet.isNotEmpty) 'pet': json.encode(pet),
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(
              '✅ [API SUCCESS] getIngredientDetail - Status: ${response.statusCode}');
        }
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        if (kDebugMode) {
          print('📋 [API RESPONSE] getIngredientDetail JSON:');
          const encoder = JsonEncoder.withIndent('  ');
          print(encoder.convert(jsonData));
        }
        return jsonData;
      } else {
        if (kDebugMode) {
          print(
              '❌ [API ERROR] getIngredientDetail - Status: ${response.statusCode}');
          print('📝 Response Body: ${response.body}');
        }
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('💥 [API EXCEPTION] getIngredientDetail - Error: $e');
      }
      throw Exception('Failed to get ingredient detail: $e');
    }
  }

  static Future<File> _resizeImage(File imageFile) async {
    // 이미지 로드
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      return imageFile;
    }

    // 가로세로 최대 1024로 리사이즈
    const maxSize = 1024;
    img.Image resized;

    if (image.width > maxSize || image.height > maxSize) {
      if (image.width > image.height) {
        resized = img.copyResize(image, width: maxSize);
      } else {
        resized = img.copyResize(image, height: maxSize);
      }
    } else {
      resized = image;
    }

    // 임시 파일로 저장
    final tempDir = await Directory.systemTemp.createTemp();
    final tempFile = File('${tempDir.path}/resized_ingredients.jpg');
    await tempFile.writeAsBytes(img.encodeJpg(resized, quality: 85));

    return tempFile;
  }
}
