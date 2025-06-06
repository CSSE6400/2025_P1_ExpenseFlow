import 'package:flutter/material.dart';
import '../../../common/proportional_sizes.dart';

class ProfileSetupScreenAvatarIcon extends StatelessWidget {
  const ProfileSetupScreenAvatarIcon({super.key});

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
      ],
    );
  }
}
