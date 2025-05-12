// Flutter imports
import 'package:flutter/material.dart';
// Common
import '../../../common/proportional_sizes.dart';

class ProfileSetupScreenAvatarIcon extends StatelessWidget {
  final bool isDarkMode;

  const ProfileSetupScreenAvatarIcon({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Stack(
      children: [
        SizedBox(
          width: proportionalSizes.scaleWidth(120),
          height: proportionalSizes.scaleHeight(120),
          child: ClipOval(
            child: Image.asset(
              'assets/stickers/user.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        // An Icon to indicate the user can change the avatar can be added here
      ],
    );
  }
}