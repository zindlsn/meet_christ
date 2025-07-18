import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';

class FileRepository {
  Future<String?> uploadImage(Uint8List? imageBytes) async {
    if (imageBytes == null || imageBytes.isEmpty) {
      return null;
    }

    try {
      final storageRef = FirebaseStorage.instanceFor(
        bucket: "gs://meet-christ-app.firebasestorage.app",
      ).ref().child('images/my_image.png');
      await storageRef.putData(imageBytes);
      return await storageRef.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> downloadImageBytes(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print('Failed to download image. Status: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error downloading image: $e');
    return null;
  }
}
}
