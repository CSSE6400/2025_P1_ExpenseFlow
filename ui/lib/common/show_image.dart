import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:photo_view/photo_view.dart';
import 'proportional_sizes.dart';
import 'icon_maker.dart';

/// Opens a full-screen zoomable image viewer.
///
/// Usage:
/// ```dart
/// showFullScreenImage(context, imageUrl: 'https://example.com/image.png');
/// ```
Future<void> showFullScreenImage(
  BuildContext context, {
  required String imageUrl,
}) async {
  final proportionalSizes = ProportionalSizes(context: context);
  final backgroundColor = ColorPalette.background;

  await showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 128),
    builder: (_) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Stack(
        children: [
          // Blurred background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withValues(alpha: 51),
            ),
          ),
          // Zoomable Image
          Center(
            child: GestureDetector(
              onTap: () {}, // Prevent closing on image tap
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 51),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: PhotoView(
                    imageProvider: NetworkImage(imageUrl),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  ),
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: proportionalSizes.scaleHeight(20),
            right: proportionalSizes.scaleWidth(30),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: proportionalSizes.scaleWidth(40),
                height: proportionalSizes.scaleHeight(40),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: IconMaker(
                  assetPath: 'assets/icons/cross.png',
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}