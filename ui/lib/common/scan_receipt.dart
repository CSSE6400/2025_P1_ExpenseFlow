import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dialogs/app_dialog_box.dart';
import 'snack_bar.dart';
import 'custom_divider.dart';
import 'icon_maker.dart';

class WebImageInfo {
  final File? file;
  final XFile? xFile;
  final String filename;
  final bool isWeb;

  WebImageInfo({
    this.file,
    this.xFile,
    required this.filename,
    required this.isWeb,
  });

  static Future<WebImageInfo?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return null;

    if (kIsWeb) {
      return WebImageInfo(
        file: null,
        xFile: pickedFile,
        filename: pickedFile.name,
        isWeb: true,
      );
    } else {
      return WebImageInfo(
        file: File(pickedFile.path),
        xFile: null,
        filename: pickedFile.name,
        isWeb: false,
      );
    }
  }

  double? getFileSizeInMB() {
    if (!isWeb && file != null) {
      final int fileSizeInBytes = file!.lengthSync();
      return fileSizeInBytes / (1024 * 1024);
    }
    return null;
  }

  Future<Uint8List> getBytes() async {
    if (isWeb && xFile != null) {
      return await xFile!.readAsBytes();
    } else if (file != null) {
      return await file!.readAsBytes();
    }
    throw Exception('No valid file source available');
  }
}

/// Call this from any screen
Future<void> handleScanReceiptUpload({required BuildContext context}) async {
  await showScanReceiptSourceOptions(
    context: context,
    onSelected: (image) async {
      if (!context.mounted) return;

      if (image != null) {
        await AppDialogBox.show(
          context,
          heading: 'Image Captured',
          description: 'Filename: ${image.filename}',
          buttonCount: 1,
          button1Text: 'OK',
          onButton1Pressed: () => Navigator.of(context).pop(),
        );
      } else {
        showCustomSnackBar(
          context,
          normalText: 'Something went wrong while uploading.',
          boldText: 'Error:',
        );
      }
    },
  );
}

/// Internal bottom sheet — lets user choose camera or gallery
Future<void> showScanReceiptSourceOptions({
  required BuildContext context,
  required Function(WebImageInfo?) onSelected,
}) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Theme(
        data: Theme.of(context).copyWith(
          splashColor: ColorPalette.primaryAction.withValues(alpha: 0.05),
          highlightColor: ColorPalette.primaryAction.withValues(alpha: 0.1),
        ),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 10,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Camera
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            final image = await WebImageInfo.pickImage(
                              ImageSource.camera,
                            );
                            onSelected(image);
                          },
                          child: ListTile(
                            leading: IconMaker(
                              assetPath: 'assets/icons/camera.png',
                            ),
                            title: Text(
                              'Take a Photo',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: ColorPalette.primaryAction,
                              ),
                            ),
                          ),
                        ),
                      ),
                      CustomDivider(),
                      // Gallery
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            final image = await WebImageInfo.pickImage(
                              ImageSource.gallery,
                            );

                            if (!kIsWeb && image != null) {
                              final size = image.getFileSizeInMB();
                              if (size != null && size > 10.0) {
                                if (context.mounted) {
                                  showCustomSnackBar(
                                    context,
                                    boldText: 'Error:',
                                    normalText: 'Image exceeds 10MB limit.',
                                  );
                                }
                                onSelected(null);
                                return;
                              }
                            }

                            onSelected(image);
                          },
                          child: ListTile(
                            leading: IconMaker(
                              assetPath: 'assets/icons/gallery.png',
                            ),
                            title: Text(
                              'Upload from Gallery',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: ColorPalette.primaryAction,
                              ),
                            ),
                          ),
                        ),
                      ),
                      CustomDivider(),
                      // Cancel
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  color: ColorPalette.error,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
