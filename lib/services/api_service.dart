import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  }) async {
    try {
      // 이미지 리사이즈
      final resizedImage = await _resizeImage(imageFile);

      // Create multipart request
      final uri = Uri.parse('$_baseUrl/analyzeIngredients');
      final request = http.MultipartRequest('POST', uri);

      // Add fields
      request.fields['category'] = category;
      request.fields['langCode'] = langCode;

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
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData;
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to analyze ingredients: $e');
    }
  }

  static Future<Map<String, dynamic>> compareIngredients({
    required File imageA,
    required File imageB,
    required String category,
    required String langCode,
  }) async {
    try {
      // 이미지 리사이즈
      final resizedImageA = await _resizeImage(imageA);
      final resizedImageB = await _resizeImage(imageB);

      // Create multipart request
      final uri = Uri.parse('$_baseUrl/compareIngredients');
      final request = http.MultipartRequest('POST', uri);

      // Add fields
      request.fields['category'] = category;
      request.fields['langCode'] = langCode;

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
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return jsonData;
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to compare ingredients: $e');
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
