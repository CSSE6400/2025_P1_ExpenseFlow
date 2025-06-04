import 'package:flutter/material.dart';
import '../../../common/proportional_sizes.dart';

class ProfileScreenAvatarIcon extends StatelessWidget {
  const ProfileScreenAvatarIcon({super.key});

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
