// Flutter Packages
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// A platform-agnostic class that encapsulates image file information.
/// It supports both mobile and web environments by conditionally using
/// `File` for mobile and `XFile` for web.
///
/// Provides utility methods for picking an image, retrieving its size,
/// and accessing the raw byte content.
class WebImageInfo {
  /// Reference to the actual image file (only used on mobile platforms)
  final File? file;

  /// XFile object used by the image_picker plugin (required for web)
  final XFile? xFile;

  /// Name of the file, used for display and storage naming
  final String filename;

  /// Flag to indicate whether the current platform is web
  final bool isWeb;

  /// Constructor for creating a [WebImageInfo] instance
  WebImageInfo({
    this.file,
    this.xFile,
    required this.filename,
    required this.isWeb,
  });

  /// Static method to allow users to select an image from the gallery.
  /// This handles the differences between web and mobile platforms internally.
  static Future<WebImageInfo?> pickImage() async {
    // Instantiate an ImagePicker
    final picker = ImagePicker();

    // Open the image picker for the gallery source
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    // If the user cancels or no file is selected, return null
    if (pickedFile == null) {
      return null;
    }

    // If running on the web, return an instance with xFile populated
    if (kIsWeb) {
      return WebImageInfo(
        file: null,
        xFile: pickedFile,
        filename: pickedFile.name,
        isWeb: true,
      );
    }
    // If running on a non-web (mobile) platform, return an instance with File populated
    else {
      return WebImageInfo(
        file: File(pickedFile.path),
        xFile: null,
        filename: pickedFile.name,
        isWeb: false,
      );
    }
  }

  /// Retrieves the size of the file in megabytes.
  /// Works only on mobile platforms where `File` is used.
  double? getFileSizeInMB() {
    if (!isWeb && file != null) {
      final int fileSizeInBytes = file!.lengthSync();
      return fileSizeInBytes / (1024 * 1024); // Convert to MB
    }
    return null;
  }

  /// Returns the image file as a byte array [Uint8List],
  /// supporting both web and mobile platforms.
  /// Throws an exception if neither `file` nor `xFile` is available.
  Future<Uint8List> getBytes() async {
    if (isWeb && xFile != null) {
      return await xFile!.readAsBytes();
    } else if (file != null) {
      return await file!.readAsBytes();
    }

    // If both file and xFile are null, throw an error
    throw Exception('No valid file source available');
  }
}