import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
  static Future<File> resizeImage(String imagePath, {int width = 1200, int height = 600}) async {
    try {
      // Read the image file
      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      
      // Decode the image
      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('Failed to decode image');
      
      // Calculate the aspect ratio
      final aspectRatio = image.width / image.height;
      final targetAspectRatio = width / height;
      
      int targetWidth;
      int targetHeight;
      
      if (aspectRatio > targetAspectRatio) {
        // Image is wider than target
        targetWidth = width;
        targetHeight = (width / aspectRatio).round();
      } else {
        // Image is taller than target
        targetHeight = height;
        targetWidth = (height * aspectRatio).round();
      }
      
      // Resize the image
      final resized = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.linear,
      );
      
      // Create a new file for the resized image
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      // Encode and save the resized image
      final encodedImage = img.encodeJpg(resized, quality: 85);
      await tempFile.writeAsBytes(encodedImage);
      
      return tempFile;
    } catch (e) {
      debugPrint('Error resizing image: $e');
      throw Exception('Failed to resize image');
    }
  }
  
  static Future<Uint8List> getImageBytes(String imagePath) async {
    final file = File(imagePath);
    return await file.readAsBytes();
  }
}