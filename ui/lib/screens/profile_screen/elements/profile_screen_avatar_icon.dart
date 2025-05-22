// Flutter imports
import 'package:flutter/material.dart';
// Common imports
import '../../../common/proportional_sizes.dart';

class ProfileScreenAvatarIcon extends StatelessWidget {
  const ProfileScreenAvatarIcon({super.key});

  /// Returns a circular avatar icon for the profile setup screen.
  /// The icon is a placeholder image and can be replaced with a user-uploaded image.
  /// The icon is sized proportionally based on the screen size.
  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Stack(
      children: [
        CircleAvatar(
          radius: proportionalSizes.scaleWidth(60),
          backgroundImage: AssetImage('assets/stickers/user.png'),
          backgroundColor: Colors.transparent,
        ),

        // An Icon to indicate the user can change the avatar can be added here
      ],
    );
  }
}