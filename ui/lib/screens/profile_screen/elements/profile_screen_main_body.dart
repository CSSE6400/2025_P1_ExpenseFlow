// Flutter imports
import 'package:flutter/material.dart';
// Common imports
import '../../../../common/proportional_sizes.dart';
// Elements
import 'profile_screen_avatar_icon.dart';
import 'profile_screen_sub_rectangle.dart';
// import 'profile_screen_sub_lower_rectangle.dart';

class ProfileScreenMainBody extends StatelessWidget {
  const ProfileScreenMainBody({super.key});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard
      },
      child: SafeArea(
        child: SingleChildScrollView(
          // Prevents overflow
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Icon
              Align(
                alignment: Alignment.topLeft,
                child: ProfileScreenAvatarIcon(),
              ),

              SizedBox(height: proportionalSizes.scaleHeight(20)),

              // Sub Rectangle
              ProfileScreenSubRectangle(),
            ],
          ),
        ),
      ),
    );
  }
}