import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:expenseflow/common/color_palette.dart';
import 'package:expenseflow/services/api_service.dart' show ApiService;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart' show Provider;
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

Future<void> handleScanReceiptUpload({required BuildContext context}) async {
  final apiService = Provider.of<ApiService>(context, listen: false);

  await showScanReceiptSourceOptions(
    context: context,
    onSelected: (image) async {
      if (!context.mounted) return;

      if (image != null) {
        try {
          // show loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          // upload image
          final expense = await apiService.expenseApi.createExpenseFromImage(
            image,
            null,
          );
          if (expense == null) {
            if (!context.mounted) return;

            Navigator.of(context).pop(); // close loading
            showCustomSnackBar(
              context,
              normalText:
                  'Scan receipt plugin is not loaded, please try again later.',
            );
            return;
          }

          // show success dialog
          if (!context.mounted) return;
          Navigator.of(context).pop();

          await AppDialogBox.show(
            context,
            heading: 'Expense Created',
            description: 'Expense Total: ${expense.expenseTotal}',
            buttonCount: 1,
            button1Text: 'OK',
            onButton1Pressed: () => Navigator.of(context).pop(),
          );
        } catch (e) {
          if (!context.mounted) return;

          Navigator.of(context).pop();

          showCustomSnackBar(
            context,
            normalText: 'Failed to create expense: ${e.toString()}',
          );
        }
      } else {
        showCustomSnackBar(
          context,
          normalText: 'Something went wrong while uploading.',
        );
      }
    },
  );
}

Future<void> showScanReceiptSourceOptions({
  required BuildContext context,
  required Function(WebImageInfo?) onSelected,
}) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Theme(
        data: Theme.of(context).copyWith(
          splashColor: ColorPalette.primaryAction.withOpacity(0.05),
          highlightColor: ColorPalette.primaryAction.withOpacity(0.1),
        ),
        child: FractionallySizedBox(
          heightFactor: 0.35,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(color: Colors.white.withOpacity(0.3)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        children: [
                          ListTile(
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
                            onTap: () async {
                              Navigator.pop(context);
                              final image = await WebImageInfo.pickImage(
                                ImageSource.camera,
                              );
                              onSelected(image);
                            },
                          ),
                          CustomDivider(),
                          ListTile(
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
                          ),
                          CustomDivider(),
                          ListTile(
                            title: Center(
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  color: ColorPalette.error,
                                ),
                              ),
                            ),
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
